//
//  ViewModelTests.swift
//  HabitHuddle-iOSTests
//

import Testing
import Foundation
@testable import HabitHuddle_iOS

// MARK: - Shared helpers

private func makeHabitDTO(id: UUID = UUID()) -> HabitDTO {
    HabitDTO(
        id: id,
        user: LightweightUser(id: UUID()),
        name: "Run",
        description: "A daily run",
        category: "Fitness",
        duration: .twoWeeks,
        reminderTime: nil,
        createdAt: Date(),
        updatedAt: Date(),
        checkIns: [],
        challenges: nil,
        icon: nil
    )
}

private func makeUserDTO(id: UUID = UUID()) -> UserDTO {
    UserDTO(id: id, username: "alice", name: "Alice", createdAt: nil, updatedAt: nil)
}

private func makeLoginResponse() -> LoginResponse {
    LoginResponse(token: "test-token", user: makeUserDTO())
}

// MARK: - LoginViewModel

@Suite("LoginViewModel")
struct LoginViewModelTests {

    @Test("loginUser sets loadedUser and loadedHabits on success")
    @MainActor
    func loginSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(makeLoginResponse())  // login call
        await mock.enqueue([HabitDTO]())          // getUserHabits call

        let vm = LoginViewModel(network: mock)
        await vm.loginUser(username: "alice", password: "secret")

        #expect(vm.errorMessage == "")
        #expect(vm.loadedUser.username == "alice")
        #expect(vm.loadedHabits.isEmpty)
    }

    @Test("loginUser sets errorMessage on failure")
    @MainActor
    func loginFailure() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.unauthorized)

        let vm = LoginViewModel(network: mock)
        await vm.loginUser(username: "alice", password: "wrong")

        #expect(!vm.errorMessage.isEmpty)
    }

    @Test("getUserHabits returns success with correct habits")
    @MainActor
    func getUserHabitsSuccess() async {
        let mock = MockNetworkManager()
        let habits = [makeHabitDTO(), makeHabitDTO()]
        await mock.enqueue(habits)

        let vm = LoginViewModel(network: mock)
        let result = await vm.getUserHabits()

        guard case let .success(loaded) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(loaded.count == 2)
    }

    @Test("getUserHabits returns failure on network error")
    @MainActor
    func getUserHabitsFailure() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.notFound)

        let vm = LoginViewModel(network: mock)
        let result = await vm.getUserHabits()

        guard case .failure = result else {
            Issue.record("Expected failure")
            return
        }
    }

    @Test("logout returns .ok on success")
    @MainActor
    func logoutSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.ok)

        let vm = LoginViewModel(network: mock)
        let result = await vm.logout()

        guard case let .success(status) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(status == .ok)
    }

    @Test("deleteMyAccount returns success status")
    @MainActor
    func deleteMyAccountSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.ok)

        let vm = LoginViewModel(network: mock)
        let result = await vm.deleteMyAccount()

        guard case let .success(status) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(status == .ok)
    }
}

// MARK: - RegistrationViewModel

@Suite("RegistrationViewModel")
struct RegistrationViewModelTests {

    @Test("registerUser sets loadedUser on success")
    @MainActor
    func registerSuccess() async throws {
        let mock = MockNetworkManager()
        await mock.enqueue(makeLoginResponse())

        let vm = RegistrationView.ViewModel(network: mock)
        try await vm.registerUser(userID: UUID(), username: "alice", name: "Alice", password: "pass123")

        #expect(vm.errorMessage == "")
        #expect(vm.loadedUser.username == "alice")
    }

    @Test("registerUser sets errorMessage on conflict")
    @MainActor
    func registerConflict() async throws {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.conflict)

        let vm = RegistrationView.ViewModel(network: mock)
        try await vm.registerUser(userID: UUID(), username: "alice", name: "Alice", password: "pass123")

        #expect(!vm.errorMessage.isEmpty)
    }
}

// MARK: - HabitDetailViewModel

@Suite("HabitDetailViewModel")
struct HabitDetailViewModelTests {

    @Test("createHabit returns success with returned DTO")
    @MainActor
    func createHabitSuccess() async {
        let mock = MockNetworkManager()
        let dto = makeHabitDTO()
        await mock.enqueue(dto)

        let vm = HabitDetailView.ViewModel(network: mock)
        vm.name = "Run"
        vm.description = "Daily run"
        vm.duration = .twoWeeks

        let result = await vm.createHabit(with: dto.id)
        guard case let .success(returned) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(returned.id == dto.id)
    }

    @Test("createHabit returns failure on network error")
    @MainActor
    func createHabitFailure() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.serverError)

        let vm = HabitDetailView.ViewModel(network: mock)
        vm.name = "Run"
        let result = await vm.createHabit(with: UUID())

        guard case .failure = result else {
            Issue.record("Expected failure")
            return
        }
    }

    @Test("updateHabit returns failure when habit is nil")
    @MainActor
    func updateHabitNoHabit() async {
        let mock = MockNetworkManager()
        let vm = HabitDetailView.ViewModel(network: mock)
        vm.habit = nil

        let result = await vm.updateHabit(with: UUID())
        guard case let .failure(error) = result else {
            Issue.record("Expected failure")
            return
        }
        #expect(error == .notFound)
    }

    @Test("checkIntoHabit returns .created status")
    @MainActor
    func checkInSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.created)

        let vm = HabitDetailView.ViewModel(network: mock)
        let result = await vm.checkIntoHabit(with: UUID())

        guard case let .success(status) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(status == .created)
    }

    @Test("deleteHabit returns success with the deleted DTO")
    @MainActor
    func deleteHabitSuccess() async {
        let mock = MockNetworkManager()
        let dto = makeHabitDTO()
        await mock.enqueue(dto)

        let vm = HabitDetailView.ViewModel(network: mock)
        let result = await vm.deleteHabit(with: dto.id)

        guard case let .success(returned) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(returned.id == dto.id)
    }
}

// MARK: - ChallengesListViewModel

@Suite("ChallengesListViewModel")
struct ChallengesListViewModelTests {

    private func makeChallengeDTO(status: ChallengeStatus, receiverUserID: UUID) -> ChallengeDTO {
        ChallengeDTO(
            id: UUID(),
            initiatorHabitID: nil,
            receiverHabitID: nil,
            habitName: "Test",
            type: .competitive,
            startDate: Date(),
            endDate: Date(),
            status: status,
            initiator: makeProgressDTO(userID: UUID()),
            receiver: makeProgressDTO(userID: receiverUserID)
        )
    }

    private func makeProgressDTO(userID: UUID) -> ChallengeDTO.UserProgressDTO {
        ChallengeDTO.UserProgressDTO(user: makeUserDTO(id: userID), progress: 0.0, checkInCount: 0, plannedDays: 14)
    }

    @Test("updateChallengeData separates pending sent vs received")
    @MainActor
    func updateChallengeDataSeparation() {
        let myID = UUID()
        let otherID = UUID()

        let vm = ChallengesListView.ViewModel(userID: myID)
        vm.challenges = [
            makeChallengeDTO(status: .pending, receiverUserID: myID),    // received
            makeChallengeDTO(status: .pending, receiverUserID: otherID), // sent
            makeChallengeDTO(status: .accepted, receiverUserID: myID),
            makeChallengeDTO(status: .declined, receiverUserID: myID),
        ]
        vm.updateChallengeData()

        #expect(vm.pendingChallengesReceived.count == 1)
        #expect(vm.pendingChallengesSent.count == 1)
        #expect(vm.acceptedChallenges.count == 1)
        #expect(vm.declinedChallenges.count == 1)
    }

    @Test("getChallenges populates challenges array")
    @MainActor
    func getChallengesSuccess() async {
        let mock = MockNetworkManager()
        let userID = UUID()
        let challenge = makeChallengeDTO(status: .accepted, receiverUserID: UUID())
        await mock.enqueue([challenge])

        let vm = ChallengesListView.ViewModel(userID: userID, network: mock)
        await vm.getChallenges(for: userID)

        #expect(vm.challenges.count == 1)
    }

    @Test("acceptChallenge returns success status")
    @MainActor
    func acceptChallengeSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.ok)

        let vm = ChallengesListView.ViewModel(userID: UUID(), network: mock)
        let result = await vm.acceptChallenge(with: UUID())

        guard case let .success(status) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(status == .ok)
    }

    @Test("rejectChallenge returns success status")
    @MainActor
    func rejectChallengeSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.ok)

        let vm = ChallengesListView.ViewModel(userID: UUID(), network: mock)
        let result = await vm.rejectChallenge(with: UUID())

        guard case let .success(status) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(status == .ok)
    }
}

// MARK: - FriendsListViewModel (MyFriendsView.ViewModel)

@Suite("FriendsListViewModel")
struct FriendsListViewModelTests {

    @Test("getMyFriendRequests populates friendRequests")
    @MainActor
    func getFriendRequestsSuccess() async {
        let mock = MockNetworkManager()
        let users = [makeUserDTO(), makeUserDTO()]
        await mock.enqueue(users)

        let vm = MyFriendsView.ViewModel(network: mock)
        await vm.getMyFriendRequests()

        #expect(vm.friendRequests.count == 2)
    }

    @Test("acceptFriend returns success with accepted user")
    @MainActor
    func acceptFriendSuccess() async {
        let mock = MockNetworkManager()
        let user = makeUserDTO()
        await mock.enqueue(user)

        let vm = MyFriendsView.ViewModel(network: mock)
        let result = await vm.acceptFriend(with: user.id)

        guard case let .success(accepted) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(accepted.id == user.id)
    }

    @Test("rejectFriend returns success status")
    @MainActor
    func rejectFriendSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.ok)

        let vm = MyFriendsView.ViewModel(network: mock)
        let result = await vm.rejectFriend(with: UUID())

        guard case let .success(status) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(status == .ok)
    }

    @Test("searchUsers with short query clears results immediately")
    @MainActor
    func searchUsersShortQuery() {
        let mock = MockNetworkManager()
        let vm = MyFriendsView.ViewModel(network: mock)
        vm.results = [makeUserDTO()]

        vm.searchUsers(query: "a")  // too short (< 2 chars)
        #expect(vm.results.isEmpty)
    }
}

// MARK: - FriendDetailViewModel

@Suite("FriendDetailViewModel")
struct FriendDetailViewModelTests {

    @Test("getUserHabits populates habits")
    @MainActor
    func getUserHabitsSuccess() async {
        let mock = MockNetworkManager()
        let habits = [makeHabitDTO(), makeHabitDTO()]
        await mock.enqueue(habits)

        let vm = FriendDetailView.ViewModel(network: mock)
        await vm.getUserHabits(for: UUID())

        #expect(vm.habits.count == 2)
    }

    @Test("deleteFriend returns success status")
    @MainActor
    func deleteFriendSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.ok)

        let vm = FriendDetailView.ViewModel(network: mock)
        let result = await vm.deleteFriend(with: UUID())

        guard case let .success(status) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(status == .ok)
    }

    @Test("deleteFriend returns failure on error")
    @MainActor
    func deleteFriendFailure() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.notFound)

        let vm = FriendDetailView.ViewModel(network: mock)
        let result = await vm.deleteFriend(with: UUID())

        guard case .failure = result else {
            Issue.record("Expected failure")
            return
        }
    }
}

// MARK: - MyFriendsListViewModel

@Suite("MyFriendsListViewModel")
struct MyFriendsListViewModelTests {

    @Test("getMyFriends populates friends")
    @MainActor
    func getMyFriendsSuccess() async {
        let mock = MockNetworkManager()
        let users = [makeUserDTO(), makeUserDTO(), makeUserDTO()]
        await mock.enqueue(users)

        let vm = MyFriendsList.ViewModel(network: mock)
        await vm.getMyFriends()

        #expect(vm.friends.count == 3)
    }

    @Test("getMyFriends keeps friends empty on error")
    @MainActor
    func getMyFriendsFailure() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.unauthorized)

        let vm = MyFriendsList.ViewModel(network: mock)
        await vm.getMyFriends()

        #expect(vm.friends.isEmpty)
    }
}

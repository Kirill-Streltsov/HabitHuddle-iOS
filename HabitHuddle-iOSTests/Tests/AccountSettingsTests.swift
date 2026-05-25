//
//  AccountSettingsTests.swift
//  HabitHuddle-iOSTests
//

import Testing
import Foundation
@testable import HabitHuddle_iOS

private func makeUser(
    id: UUID = UUID(),
    username: String = "alice",
    name: String = "Alice",
    email: String? = "alice@example.com",
    isEmailVerified: Bool = true
) -> UserDTO {
    UserDTO(
        id: id,
        username: username,
        name: name,
        email: email,
        isEmailVerified: isEmailVerified,
        createdAt: Date(),
        updatedAt: Date()
    )
}

// MARK: - updateName

@Suite("AccountSettingsViewModel.updateName")
struct AccountSettingsUpdateNameTests {

    @Test("empty name shows error and doesn't call the network")
    @MainActor
    func emptyName() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.updateName(newName: "   ", currentName: "Alice")

        #expect(!vm.errorMessage.isEmpty)
        #expect(vm.lastUpdatedUser == nil)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("unchanged name silently no-ops")
    @MainActor
    func unchangedName() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.updateName(newName: "Alice", currentName: "Alice")

        #expect(vm.errorMessage == "")
        #expect(vm.lastUpdatedUser == nil)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("success sets lastUpdatedUser")
    @MainActor
    func success() async {
        let mock = MockNetworkManager()
        await mock.enqueue(makeUser(name: "Alicia"))

        let vm = AccountSettingsViewModel(network: mock)
        await vm.updateName(newName: "Alicia", currentName: "Alice")

        #expect(vm.lastUpdatedUser?.name == "Alicia")
        #expect(vm.errorMessage == "")
        let log = await mock.requestLog
        #expect(log.first?.path == "users/me")
        #expect(log.first?.method == .put)
    }

    @Test("trims whitespace before submitting")
    @MainActor
    func trimsWhitespace() async {
        let mock = MockNetworkManager()
        await mock.enqueue(makeUser(name: "Alicia"))

        let vm = AccountSettingsViewModel(network: mock)
        await vm.updateName(newName: "  Alicia  ", currentName: "Alice")

        #expect(vm.lastUpdatedUser?.name == "Alicia")
    }

    @Test("network error sets errorMessage")
    @MainActor
    func networkError() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.serverError)

        let vm = AccountSettingsViewModel(network: mock)
        await vm.updateName(newName: "Alicia", currentName: "Alice")

        #expect(vm.lastUpdatedUser == nil)
        #expect(!vm.errorMessage.isEmpty)
    }
}

// MARK: - updateUsername

@Suite("AccountSettingsViewModel.updateUsername")
struct AccountSettingsUpdateUsernameTests {

    @Test("rejects username shorter than 3 characters")
    @MainActor
    func tooShort() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.updateUsername(newUsername: "ab", currentUsername: "alice")

        #expect(!vm.errorMessage.isEmpty)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("unchanged username silently no-ops")
    @MainActor
    func unchanged() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.updateUsername(newUsername: "alice", currentUsername: "alice")

        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("success sets lastUpdatedUser")
    @MainActor
    func success() async {
        let mock = MockNetworkManager()
        await mock.enqueue(makeUser(username: "alice_new"))

        let vm = AccountSettingsViewModel(network: mock)
        await vm.updateUsername(newUsername: "alice_new", currentUsername: "alice")

        #expect(vm.lastUpdatedUser?.username == "alice_new")
    }

    @Test("conflict from server surfaces a non-empty error")
    @MainActor
    func conflict() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.conflict)

        let vm = AccountSettingsViewModel(network: mock)
        await vm.updateUsername(newUsername: "alice_new", currentUsername: "alice")

        #expect(vm.lastUpdatedUser == nil)
        #expect(!vm.errorMessage.isEmpty)
    }
}

// MARK: - updateEmail

@Suite("AccountSettingsViewModel.updateEmail")
struct AccountSettingsUpdateEmailTests {

    @Test("invalid email is rejected")
    @MainActor
    func invalidEmail() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.updateEmail(newEmail: "not-an-email", currentEmail: "alice@example.com", currentPassword: "secret")

        #expect(!vm.errorMessage.isEmpty)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("missing current password is rejected")
    @MainActor
    func missingPassword() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.updateEmail(newEmail: "new@example.com", currentEmail: "alice@example.com", currentPassword: "")

        #expect(!vm.errorMessage.isEmpty)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("unchanged email silently no-ops")
    @MainActor
    func unchangedEmail() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.updateEmail(newEmail: "Alice@Example.com", currentEmail: "alice@example.com", currentPassword: "secret")

        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("success flags email verification sent")
    @MainActor
    func success() async {
        let mock = MockNetworkManager()
        await mock.enqueue(makeUser(email: "new@example.com", isEmailVerified: false))

        let vm = AccountSettingsViewModel(network: mock)
        await vm.updateEmail(newEmail: "new@example.com", currentEmail: "alice@example.com", currentPassword: "secret")

        #expect(vm.lastUpdatedUser?.email == "new@example.com")
        #expect(vm.didSendEmailVerification == true)
    }

    @Test("unauthorized response surfaces an error and does not flag verification sent")
    @MainActor
    func unauthorized() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.unauthorized)

        let vm = AccountSettingsViewModel(network: mock)
        await vm.updateEmail(newEmail: "new@example.com", currentEmail: "alice@example.com", currentPassword: "wrong")

        #expect(vm.lastUpdatedUser == nil)
        #expect(vm.didSendEmailVerification == false)
        #expect(!vm.errorMessage.isEmpty)
    }
}

// MARK: - changePassword

@Suite("AccountSettingsViewModel.changePassword")
struct AccountSettingsChangePasswordTests {

    @Test("empty current password is rejected")
    @MainActor
    func emptyCurrent() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.changePassword(currentPassword: "", newPassword: "newpass1", confirmPassword: "newpass1")

        #expect(!vm.errorMessage.isEmpty)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("short new password is rejected")
    @MainActor
    func shortNew() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.changePassword(currentPassword: "secret", newPassword: "abc", confirmPassword: "abc")

        #expect(!vm.errorMessage.isEmpty)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("mismatched confirmation is rejected")
    @MainActor
    func mismatch() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.changePassword(currentPassword: "secret", newPassword: "newpass1", confirmPassword: "newpass2")

        #expect(!vm.errorMessage.isEmpty)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("new password identical to current is rejected")
    @MainActor
    func sameAsCurrent() async {
        let mock = MockNetworkManager()
        let vm = AccountSettingsViewModel(network: mock)

        await vm.changePassword(currentPassword: "secret123", newPassword: "secret123", confirmPassword: "secret123")

        #expect(!vm.errorMessage.isEmpty)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("success sets lastUpdatedUser")
    @MainActor
    func success() async {
        let mock = MockNetworkManager()
        await mock.enqueue(makeUser())

        let vm = AccountSettingsViewModel(network: mock)
        await vm.changePassword(currentPassword: "secret", newPassword: "newpassword1", confirmPassword: "newpassword1")

        #expect(vm.lastUpdatedUser != nil)
        #expect(vm.errorMessage == "")
        let log = await mock.requestLog
        #expect(log.first?.path == "users/me")
        #expect(log.first?.method == .put)
    }

    @Test("unauthorized response surfaces a non-empty error")
    @MainActor
    func unauthorized() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.unauthorized)

        let vm = AccountSettingsViewModel(network: mock)
        await vm.changePassword(currentPassword: "wrong", newPassword: "newpassword1", confirmPassword: "newpassword1")

        #expect(vm.lastUpdatedUser == nil)
        #expect(!vm.errorMessage.isEmpty)
    }
}

//
//  EndpointTests.swift
//  HabitHuddle-iOSTests
//

import Testing
import Foundation
@testable import HabitHuddle_iOS

@Suite("Endpoint path construction")
struct EndpointTests {

    // MARK: - Habits

    @Test("createHabit path")
    func createHabitPath() {
        #expect(Endpoint.createHabit().path == "habits")
    }

    @Test("updateHabit path includes ID")
    func updateHabitPath() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        #expect(Endpoint.updateHabit(with: id).path == "habits/00000000-0000-0000-0000-000000000001")
    }

    @Test("deleteHabit path includes ID")
    func deleteHabitPath() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        #expect(Endpoint.deleteHabit(with: id).path == "habits/00000000-0000-0000-0000-000000000002")
    }

    @Test("checkIntoHabit path includes toggle-checkin suffix")
    func checkInPath() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        #expect(Endpoint.checkIntoHabit(with: id).path == "habits/00000000-0000-0000-0000-000000000003/toggle-checkin")
    }

    @Test("getHabitCheckIns path ends with /checkins")
    func checkInsPath() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
        #expect(Endpoint.getHabitCheckIns(for: id).path == "habits/00000000-0000-0000-0000-000000000004/checkins")
    }

    @Test("askOpenAI has correct query items")
    func askOpenAIQueryItems() {
        let endpoint = Endpoint.askOpenAI(habitName: "Run", habitDescription: "A daily run", habitDuration: 14)
        #expect(endpoint.path == "habits/ask-open-ai")
        let items = endpoint.queryItems ?? []
        #expect(items.first(where: { $0.name == "name" })?.value == "Run")
        #expect(items.first(where: { $0.name == "description" })?.value == "A daily run")
        #expect(items.first(where: { $0.name == "duration" })?.value == "14")
    }

    @Test("askOpenAI has no query items when names are empty")
    func askOpenAIHasThreeQueryItems() {
        let endpoint = Endpoint.askOpenAI(habitName: "", habitDescription: "", habitDuration: 7)
        #expect((endpoint.queryItems ?? []).count == 3)
    }

    // MARK: - Users

    @Test("getUserHabits path includes user ID")
    func getUserHabitsPath() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
        #expect(Endpoint.getUserHabits(for: id).path == "users/00000000-0000-0000-0000-000000000005/habits")
    }

    @Test("searchForUser has query item")
    func searchForUserQueryItem() {
        let endpoint = Endpoint.searchForUser(username: "alice")
        #expect(endpoint.path == "users/search")
        #expect(endpoint.queryItems?.first?.name == "query")
        #expect(endpoint.queryItems?.first?.value == "alice")
    }

    // MARK: - Auth

    @Test("login path")
    func loginPath() {
        #expect(Endpoint.login().path == "auth/login")
    }

    @Test("logout path")
    func logoutPath() {
        #expect(Endpoint.logout().path == "auth/logout")
    }

    @Test("register path")
    func registerPath() {
        #expect(Endpoint.register().path == "auth/register")
    }

    @Test("verifyEmail carries the token as a query item")
    func verifyEmailQueryItem() {
        let endpoint = Endpoint.verifyEmail(token: "abc123")
        #expect(endpoint.path == "auth/verify-email")
        #expect(endpoint.queryItems?.first?.name == "token")
        #expect(endpoint.queryItems?.first?.value == "abc123")
    }

    // MARK: - Friends

    @Test("requestFriend path")
    func requestFriendPath() {
        #expect(Endpoint.requestFriend().path == "friends/request")
    }

    @Test("acceptFriend path includes ID")
    func acceptFriendPath() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!
        #expect(Endpoint.acceptFriend(with: id).path == "friends/accept/00000000-0000-0000-0000-000000000006")
    }

    @Test("boostFriend path includes both IDs")
    func boostFriendPath() {
        let friendID = UUID(uuidString: "00000000-0000-0000-0000-000000000007")!
        let habitID = UUID(uuidString: "00000000-0000-0000-0000-000000000008")!
        let path = Endpoint.boostFriend(friendID, about: habitID).path
        #expect(path.contains("00000000-0000-0000-0000-000000000007"))
        #expect(path.contains("00000000-0000-0000-0000-000000000008"))
    }

    // MARK: - Challenges

    @Test("acceptChallenge path includes /accept")
    func acceptChallengePath() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000009")!
        let path = Endpoint.acceptChallenge(id: id).path
        #expect(path.contains("accept"))
        #expect(path.contains("00000000-0000-0000-0000-000000000009"))
    }

    @Test("rejectChallenge path includes /reject")
    func rejectChallengePath() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000009")!
        let path = Endpoint.rejectChallenge(id: id).path
        #expect(path.contains("reject"))
    }

    @Test("cancelChallenge path includes /cancel")
    func cancelChallengePath() {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000009")!
        let path = Endpoint.cancelChallenge(id: id).path
        #expect(path.contains("cancel"))
    }
}

// Regression coverage for the bug where requestStatusCode built its URL without the
// endpoint's query items, dropping the email-verification token and producing a
// spurious "verification link is no longer valid" alert.
@Suite("NetworkManager.makeURL")
struct MakeURLTests {

    private let baseURL = URL(string: "https://example.com/api/")!

    @Test("query items are appended to the final URL")
    func appendsQueryItems() throws {
        let url = try NetworkManager.makeURL(baseURL: baseURL, endpoint: .verifyEmail(token: "abc123"))
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(url.path.hasSuffix("auth/verify-email"))
        #expect(components?.queryItems?.first(where: { $0.name == "token" })?.value == "abc123")
    }

    @Test("token with reserved characters is percent-encoded, not lost")
    func encodesReservedCharacters() throws {
        let url = try NetworkManager.makeURL(baseURL: baseURL, endpoint: .verifyEmail(token: "a b+c/d"))
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.first(where: { $0.name == "token" })?.value == "a b+c/d")
    }

    @Test("path-only endpoint produces no query string")
    func noQueryItems() throws {
        let url = try NetworkManager.makeURL(baseURL: baseURL, endpoint: .login())
        #expect(url.path.hasSuffix("auth/login"))
        #expect(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems == nil)
    }
}

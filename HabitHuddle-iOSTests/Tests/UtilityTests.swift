//
//  UtilityTests.swift
//  HabitHuddle-iOSTests
//

import Testing
import Foundation
@testable import HabitHuddle_iOS

// MARK: - HTTPStatus

@Suite("HTTPStatus")
struct HTTPStatusTests {

    @Test("200 maps to .ok")
    func status200() {
        #expect(HTTPStatus(statusCode: 200) == .ok)
    }

    @Test("201 maps to .created")
    func status201() {
        #expect(HTTPStatus(statusCode: 201) == .created)
    }

    @Test("401 maps to .unauthorized")
    func status401() {
        #expect(HTTPStatus(statusCode: 401) == .unauthorized)
    }

    @Test("404 maps to .notFound")
    func status404() {
        #expect(HTTPStatus(statusCode: 404) == .notFound)
    }

    @Test("409 maps to .conflict")
    func status409() {
        #expect(HTTPStatus(statusCode: 409) == .conflict)
    }

    @Test("500 maps to .serverError")
    func status500() {
        #expect(HTTPStatus(statusCode: 500) == .serverError)
    }

    @Test("unknown code falls back to .serverError")
    func statusUnknown() {
        // 204 No Content is not in the enum — should fall back to .serverError
        #expect(HTTPStatus(statusCode: 204) == .serverError)
    }
}

// MARK: - HHError

@Suite("HHError")
struct HHErrorTests {

    @Test("Two .unauthorized errors are equal")
    func equalSimpleCases() {
        #expect(HHError.unauthorized == HHError.unauthorized)
    }

    @Test("Different simple cases are not equal")
    func unequalSimpleCases() {
        #expect(HHError.unauthorized != HHError.notFound)
    }

    @Test(".requestFailed equality uses status code only")
    func requestFailedEquality() {
        let a = HHError.requestFailed(statusCode: 422, data: nil)
        let b = HHError.requestFailed(statusCode: 422, data: Data("test".utf8))
        #expect(a == b)
    }

    @Test(".requestFailed with different codes are not equal")
    func requestFailedDifferentCodes() {
        let a = HHError.requestFailed(statusCode: 422, data: nil)
        let b = HHError.requestFailed(statusCode: 400, data: nil)
        #expect(a != b)
    }

    @Test(".partialFailure equality uses id sets")
    func partialFailureEquality() {
        let id = UUID()
        let dto = HabitDTO(id: id, user: LightweightUser(id: UUID()), name: "", description: "", category: "", duration: .oneWeek, reminderTime: nil, createdAt: nil, updatedAt: nil, checkIns: nil, challenges: nil, icon: nil)
        let a = HHError.partialFailure(updated: [dto], failedIDs: [id])
        let b = HHError.partialFailure(updated: [dto], failedIDs: [id])
        #expect(a == b)
    }

    @Test("errorDescription is non-empty for all cases")
    func errorDescriptions() {
        let errors: [HHError] = [
            .invalidURL, .unauthorized, .forbidden, .notFound, .conflict,
            .serverError, .noData, .invalidResponse, .unknown,
            .requestFailed(statusCode: 400, data: nil),
            .customError(errorText: "oops"),
        ]
        for error in errors {
            #expect(!(error.errorDescription ?? "").isEmpty, "Empty description for \(error)")
        }
    }
}

// MARK: - Helpers.handleResult

@Suite("Helpers.handleResult")
struct HelpersTests {

    @Test("onSuccess is called for .success")
    func handleResultSuccess() {
        var called = false
        Helpers.handleResult(.success(42)) { value in
            called = true
            #expect(value == 42)
        }
        #expect(called)
    }

    @Test("onFailure is called for .failure")
    func handleResultFailure() {
        var failureCalled = false
        Helpers.handleResult(Result<Int, HHError>.failure(.notFound)) { _ in
            Issue.record("onSuccess should not be called")
        } onFailure: { error in
            failureCalled = true
            #expect(error == .notFound)
        }
        #expect(failureCalled)
    }

    @Test("default error handler is used when onFailure is nil")
    func handleResultDefaultFailure() {
        // Just verifying this doesn't crash; the print goes to console
        Helpers.handleResult(Result<Int, HHError>.failure(.serverError)) { _ in
            Issue.record("Should not succeed")
        }
    }
}

// MARK: - HabitDuration

@Suite("HabitDuration")
struct HabitDurationTests {

    @Test("oneWeek has 7 days")
    func oneWeek() {
        #expect(HabitDuration.oneWeek.numberOfDays == 7)
    }

    @Test("twoWeeks has 14 days")
    func twoWeeks() {
        #expect(HabitDuration.twoWeeks.numberOfDays == 14)
    }

    @Test("oneMonth has 30 days")
    func oneMonth() {
        #expect(HabitDuration.oneMonth.numberOfDays == 30)
    }

    @Test("rawValue round-trips through init")
    func rawValueRoundTrip() {
        for duration in HabitDuration.allCases {
            #expect(HabitDuration(rawValue: duration.rawValue) == duration)
        }
    }
}

// MARK: - ChallengeDetailViewModel

@Suite("ChallengeDetailViewModel")
struct ChallengeDetailViewModelTests {

    private func makeCheckInDTO(daysAgo: Int = 0) -> HabitCheckInDTO {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        return HabitCheckInDTO(date: date, habit: LightweightHabit(id: UUID()))
    }

    @Test("both IDs nil — both date arrays stay empty")
    @MainActor
    func bothIDsNil() async {
        let mock = MockNetworkManager()
        let vm = ChallengeCheckInsListView.ViewModel(network: mock)

        await vm.getCheckInDates(forInitiator: nil, forReceiver: nil)

        #expect(vm.initiatorDates.isEmpty)
        #expect(vm.receiverDates.isEmpty)
    }

    @Test("initiator ID nil — only receiver dates are fetched")
    @MainActor
    func initiatorIDNil() async {
        let mock = MockNetworkManager()
        await mock.enqueue([makeCheckInDTO()])

        let vm = ChallengeCheckInsListView.ViewModel(network: mock)
        await vm.getCheckInDates(forInitiator: nil, forReceiver: UUID())

        #expect(vm.initiatorDates.isEmpty)
        #expect(vm.receiverDates.count == 1)
    }

    @Test("receiver ID nil — only initiator dates are fetched")
    @MainActor
    func receiverIDNil() async {
        let mock = MockNetworkManager()
        await mock.enqueue([makeCheckInDTO()])

        let vm = ChallengeCheckInsListView.ViewModel(network: mock)
        await vm.getCheckInDates(forInitiator: UUID(), forReceiver: nil)

        #expect(vm.initiatorDates.count == 1)
        #expect(vm.receiverDates.isEmpty)
    }

    @Test("both IDs provided — both arrays are populated")
    @MainActor
    func bothIDsProvided() async {
        let mock = MockNetworkManager()
        // Two equal-size responses: order-independent, we just verify both arrays are non-empty
        await mock.enqueue([makeCheckInDTO()])
        await mock.enqueue([makeCheckInDTO()])

        let vm = ChallengeCheckInsListView.ViewModel(network: mock)
        await vm.getCheckInDates(forInitiator: UUID(), forReceiver: UUID())

        #expect(!vm.initiatorDates.isEmpty)
        #expect(!vm.receiverDates.isEmpty)
    }

    @Test("one fetch fails — the other array still populates")
    @MainActor
    func oneFetchFails() async {
        let mock = MockNetworkManager()
        // One error + one success; concurrent tasks dequeue in non-deterministic order,
        // so we only assert the aggregate: exactly one array ends up with data.
        await mock.enqueueError(HHError.notFound)
        await mock.enqueue([makeCheckInDTO()])

        let vm = ChallengeCheckInsListView.ViewModel(network: mock)
        await vm.getCheckInDates(forInitiator: UUID(), forReceiver: UUID())

        let total = vm.initiatorDates.count + vm.receiverDates.count
        #expect(total == 1)
    }

    @Test("both fetches fail — both arrays stay empty")
    @MainActor
    func bothFetchFail() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.serverError)
        await mock.enqueueError(HHError.serverError)

        let vm = ChallengeCheckInsListView.ViewModel(network: mock)
        await vm.getCheckInDates(forInitiator: UUID(), forReceiver: UUID())

        #expect(vm.initiatorDates.isEmpty)
        #expect(vm.receiverDates.isEmpty)
    }

    @Test("dates are mapped correctly from check-in DTOs")
    @MainActor
    func dateMappingIsCorrect() async {
        let mock = MockNetworkManager()
        let expectedDate = Date(timeIntervalSince1970: 1_700_000_000)
        // Pass forReceiver: nil so only one network call is made — no ordering ambiguity
        await mock.enqueue([HabitCheckInDTO(date: expectedDate, habit: LightweightHabit(id: UUID()))])

        let vm = ChallengeCheckInsListView.ViewModel(network: mock)
        await vm.getCheckInDates(forInitiator: UUID(), forReceiver: nil)

        #expect(vm.initiatorDates.first == expectedDate)
        #expect(vm.receiverDates.isEmpty)
    }
}

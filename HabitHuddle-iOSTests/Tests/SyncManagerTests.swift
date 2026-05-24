//
//  SyncManagerTests.swift
//  HabitHuddle-iOSTests
//

import Testing
import SwiftData
import Foundation
@testable import HabitHuddle_iOS

@Suite("SyncManager")
struct SyncManagerTests {

    // MARK: - Helpers

    private func makeHabitDTO(id: UUID = UUID()) -> HabitDTO {
        HabitDTO(
            id: id,
            user: LightweightUser(id: UUID()),
            name: "Test Habit",
            description: "",
            category: "",
            duration: .twoWeeks,
            reminderTime: nil,
            createdAt: Date(),
            updatedAt: Date(),
            checkIns: [],
            challenges: nil,
            icon: nil
        )
    }

    // MARK: - getHabitsFromServer

    @Test("getHabitsFromServer returns success when network succeeds")
    @MainActor
    func getHabitsFromServerSuccess() async {
        let mock = MockNetworkManager()
        let expected = [makeHabitDTO(), makeHabitDTO()]
        await mock.enqueue(expected)

        let sut = SyncManager(network: mock)
        let result = await sut.getHabitsFromServer()

        guard case let .success(habits) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(habits.count == 2)
        #expect(habits.map(\.id) == expected.map(\.id))
    }

    @Test("getHabitsFromServer returns failure when network throws")
    @MainActor
    func getHabitsFromServerFailure() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.serverError)

        let sut = SyncManager(network: mock)
        let result = await sut.getHabitsFromServer()

        guard case .failure = result else {
            Issue.record("Expected failure")
            return
        }
    }

    // MARK: - createHabitsOnTheServer

    @Test("createHabitsOnTheServer returns empty success for empty input")
    @MainActor
    func createHabitsEmptyInput() async {
        let mock = MockNetworkManager()
        let sut = SyncManager(network: mock)
        let result = await sut.createHabitsOnTheServer(with: [])

        guard case let .success(habits) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(habits.isEmpty)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("createHabitsOnTheServer succeeds when network returns created habits")
    @MainActor
    func createHabitsSuccess() async {
        let mock = MockNetworkManager()
        let habitID = UUID()
        let dto = makeHabitDTO(id: habitID)
        await mock.enqueue(dto)

        let sut = SyncManager(network: mock)
        let payload = HabitPayload(
            id: habitID,
            name: "Test",
            description: nil,
            isPublic: false,
            category: nil,
            icon: nil,
            duration: HabitDuration.twoWeeks.rawValue,
            reminderTime: nil,
            checkIns: [],
            challenges: []
        )

        let result = await sut.createHabitsOnTheServer(with: [payload])
        guard case let .success(habits) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(habits.count == 1)
        #expect(habits.first?.id == habitID)
    }

    @Test("createHabitsOnTheServer reports partialFailure when one habit fails")
    @MainActor
    func createHabitsPartialFailure() async {
        let mock = MockNetworkManager()
        let dto1 = makeHabitDTO()
        await mock.enqueue(dto1)
        await mock.enqueueError(HHError.serverError)

        let sut = SyncManager(network: mock)
        let payloads = [
            HabitPayload(id: UUID(), name: "A", description: nil, isPublic: false, category: nil, icon: nil, duration: "oneWeek", reminderTime: nil, checkIns: [], challenges: []),
            HabitPayload(id: UUID(), name: "B", description: nil, isPublic: false, category: nil, icon: nil, duration: "oneWeek", reminderTime: nil, checkIns: [], challenges: []),
        ]

        let result = await sut.createHabitsOnTheServer(with: payloads)
        guard case let .failure(error) = result else {
            Issue.record("Expected failure")
            return
        }
        if case let .partialFailure(updated, failedIDs) = error {
            #expect(updated.count == 1)
            #expect(failedIDs.count == 1)
        } else {
            Issue.record("Expected partialFailure, got \(error)")
        }
    }

    // MARK: - deleteHabitsOnTheServer

    @Test("deleteHabitsOnTheServer returns empty success for empty input")
    @MainActor
    func deleteHabitsEmptyInput() async {
        let mock = MockNetworkManager()
        let sut = SyncManager(network: mock)
        let result = await sut.deleteHabitsOnTheServer(with: [])

        guard case let .success(habits) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(habits.isEmpty)
    }

    // MARK: - performFullSync (bug regression)

    @Test("performFullSync with empty local habits does NOT delete server habits")
    @MainActor
    func performFullSyncEmptyLocalDoesNotDelete() async throws {
        let container = try ModelContainerHelper.makeInMemory()
        let context = ModelContext(container)

        let mock = MockNetworkManager()
        // Server returns two habits
        let serverHabits = [makeHabitDTO(), makeHabitDTO()]
        await mock.enqueue(serverHabits) // for getHabitsFromServer

        let sut = SyncManager(network: mock)
        await sut.performFullSync(localHabits: [], in: context)

        // After the fix: early return means no further network calls (no delete/create/update)
        let log = await mock.requestLog
        // Only one request: GET habits from server
        #expect(log.count == 1)
        #expect(log.first?.method == .get)
    }

    @Test("performFullSync with empty local and empty server does nothing")
    @MainActor
    func performFullSyncBothEmpty() async throws {
        let container = try ModelContainerHelper.makeInMemory()
        let context = ModelContext(container)

        let mock = MockNetworkManager()
        let emptyHabits: [HabitDTO] = []
        await mock.enqueue(emptyHabits)

        let sut = SyncManager(network: mock)
        await sut.performFullSync(localHabits: [], in: context)

        let log = await mock.requestLog
        #expect(log.count == 1)
    }
}

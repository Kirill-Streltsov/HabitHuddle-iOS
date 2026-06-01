//
//  ManageCategoriesViewModelTests.swift
//  HabitHuddle-iOSTests
//

import Testing
import SwiftData
import Foundation
@testable import HabitHuddle_iOS

@Suite("ManageCategoriesViewModel")
struct ManageCategoriesViewModelTests {

    // MARK: - Helpers

    @MainActor
    private func makeContext() throws -> ModelContext {
        let container = try ModelContainerHelper.makeInMemory()
        return ModelContext(container)
    }

    private func makeHabit(category: String, isSyncable: Bool = false) -> Habit {
        Habit(
            id: UUID(),
            user: LightweightUser(id: UUID()),
            name: "Habit",
            description: "",
            isSyncable: isSyncable,
            category: category,
            duration: .twoWeeks
        )
    }

    private func makeHabitDTO(id: UUID = UUID()) -> HabitDTO {
        HabitDTO(
            id: id,
            user: LightweightUser(id: UUID()),
            name: "Habit",
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

    @MainActor
    private func makeViewModel(_ mock: MockNetworkManager = MockNetworkManager()) -> ManageCategoriesViewModel {
        ManageCategoriesViewModel(syncManager: SyncManager(network: mock))
    }

    // MARK: - summaries

    @Test("summaries groups non-empty categories with counts, sorted alphabetically")
    @MainActor
    func summariesGroupsAndSorts() {
        let vm = makeViewModel()
        let habits = [
            makeHabit(category: "Mindfulness"),
            makeHabit(category: "Fitness"),
            makeHabit(category: "Fitness"),
            makeHabit(category: ""),
        ]

        let summaries = vm.summaries(for: habits)

        #expect(summaries.map(\.name) == ["Fitness", "Mindfulness"])
        #expect(summaries.first?.habitCount == 2)
        #expect(summaries.last?.habitCount == 1)
    }

    @Test("summaries returns empty when no habit has a category and no defaults are passed")
    @MainActor
    func summariesEmpty() {
        let vm = makeViewModel()
        let summaries = vm.summaries(for: [makeHabit(category: ""), makeHabit(category: "")])
        #expect(summaries.isEmpty)
    }

    @Test("summaries surfaces always-shown categories with a zero count even when unused")
    @MainActor
    func summariesIncludesDefaults() {
        let vm = makeViewModel()
        let summaries = vm.summaries(for: [], including: ["Health", "Fitness"])

        #expect(summaries.map(\.name) == ["Fitness", "Health"])
        #expect(summaries.allSatisfy { $0.habitCount == 0 })
    }

    @Test("summaries merges always-shown defaults with in-use categories and counts each correctly")
    @MainActor
    func summariesMergesDefaultsWithUsage() {
        let vm = makeViewModel()
        let habits = [
            makeHabit(category: "Fitness"),
            makeHabit(category: "Fitness"),
            makeHabit(category: "Custom"),
        ]

        let summaries = vm.summaries(for: habits, including: ["Health", "Fitness"])

        // Custom (in use) + Health (default, unused) + Fitness (default & in use), de-duplicated.
        #expect(summaries.map(\.name) == ["Custom", "Fitness", "Health"])
        #expect(summaries.first { $0.name == "Fitness" }?.habitCount == 2)
        #expect(summaries.first { $0.name == "Custom" }?.habitCount == 1)
        #expect(summaries.first { $0.name == "Health" }?.habitCount == 0)
    }

    // MARK: - rename

    @Test("rename updates every habit using the old category")
    @MainActor
    func renameUpdatesMatchingHabits() async throws {
        let context = try makeContext()
        let vm = makeViewModel()
        let a = makeHabit(category: "Old")
        let b = makeHabit(category: "Old")
        let c = makeHabit(category: "Other")
        [a, b, c].forEach { context.insert($0) }

        let didChange = await vm.rename("Old", to: "New", in: [a, b, c], context: context, syncsToServer: false)

        #expect(didChange)
        #expect(a.category == "New")
        #expect(b.category == "New")
        #expect(c.category == "Other")
    }

    @Test("rename trims whitespace from the new name")
    @MainActor
    func renameTrimsWhitespace() async throws {
        let context = try makeContext()
        let vm = makeViewModel()
        let habit = makeHabit(category: "Old")
        context.insert(habit)

        _ = await vm.rename("Old", to: "  New  ", in: [habit], context: context, syncsToServer: false)

        #expect(habit.category == "New")
    }

    @Test("rename to an empty name is a no-op")
    @MainActor
    func renameEmptyNameNoOp() async throws {
        let context = try makeContext()
        let vm = makeViewModel()
        let habit = makeHabit(category: "Old")
        context.insert(habit)

        let didChange = await vm.rename("Old", to: "   ", in: [habit], context: context, syncsToServer: false)

        #expect(!didChange)
        #expect(habit.category == "Old")
    }

    @Test("rename to the same name is a no-op")
    @MainActor
    func renameSameNameNoOp() async throws {
        let context = try makeContext()
        let vm = makeViewModel()
        let habit = makeHabit(category: "Old")
        context.insert(habit)

        let didChange = await vm.rename("Old", to: "Old", in: [habit], context: context, syncsToServer: false)

        #expect(!didChange)
    }

    @Test("rename onto an existing category merges them")
    @MainActor
    func renameMergesIntoExisting() async throws {
        let context = try makeContext()
        let vm = makeViewModel()
        let a = makeHabit(category: "Work")
        let b = makeHabit(category: "Job")
        [a, b].forEach { context.insert($0) }

        _ = await vm.rename("Job", to: "Work", in: [a, b], context: context, syncsToServer: false)

        let summaries = vm.summaries(for: [a, b])
        #expect(summaries.count == 1)
        #expect(summaries.first?.name == "Work")
        #expect(summaries.first?.habitCount == 2)
    }

    // MARK: - delete

    @Test("delete clears the category from every habit using it")
    @MainActor
    func deleteClearsCategory() async throws {
        let context = try makeContext()
        let vm = makeViewModel()
        let a = makeHabit(category: "Trash")
        let b = makeHabit(category: "Trash")
        let c = makeHabit(category: "Keep")
        [a, b, c].forEach { context.insert($0) }

        let didChange = await vm.delete("Trash", in: [a, b, c], context: context, syncsToServer: false)

        #expect(didChange)
        #expect(a.category.isEmpty)
        #expect(b.category.isEmpty)
        #expect(c.category == "Keep")
    }

    @Test("delete of a non-existent category is a no-op")
    @MainActor
    func deleteMissingNoOp() async throws {
        let context = try makeContext()
        let vm = makeViewModel()
        let habit = makeHabit(category: "Keep")
        context.insert(habit)

        let didChange = await vm.delete("Ghost", in: [habit], context: context, syncsToServer: false)

        #expect(!didChange)
        #expect(habit.category == "Keep")
    }

    // MARK: - server sync

    @Test("rename pushes only syncable habits to the server")
    @MainActor
    func renamePushesSyncableOnly() async throws {
        let mock = MockNetworkManager()
        await mock.enqueue(makeHabitDTO())   // for syncable habit 1
        await mock.enqueue(makeHabitDTO())   // for syncable habit 2

        let context = try makeContext()
        let vm = makeViewModel(mock)
        let synced1 = makeHabit(category: "Old", isSyncable: true)
        let synced2 = makeHabit(category: "Old", isSyncable: true)
        let local = makeHabit(category: "Old", isSyncable: false)
        [synced1, synced2, local].forEach { context.insert($0) }

        let didChange = await vm.rename("Old", to: "New", in: [synced1, synced2, local], context: context, syncsToServer: true)

        #expect(didChange)
        let log = await mock.requestLog
        #expect(log.count == 2)
        #expect(log.allSatisfy { $0.method == .put })
        #expect(log.allSatisfy { $0.path.hasPrefix("habits/") })
    }

    @Test("delete does not contact the server when syncing is off")
    @MainActor
    func deleteSkipsServerWhenOff() async throws {
        let mock = MockNetworkManager()
        let context = try makeContext()
        let vm = makeViewModel(mock)
        let habit = makeHabit(category: "Old", isSyncable: true)
        context.insert(habit)

        _ = await vm.delete("Old", in: [habit], context: context, syncsToServer: false)

        let log = await mock.requestLog
        #expect(log.isEmpty)
    }
}

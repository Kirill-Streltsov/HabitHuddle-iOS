//
//  ManageCategoriesViewModel.swift
//  HabitHuddle-iOS
//

import SwiftData
import SwiftUI

@MainActor
final class ManageCategoriesViewModel: ObservableObject {

    /// A category as surfaced to the UI: its name plus how many habits currently use it.
    struct CategorySummary: Identifiable, Equatable {
        let name: String
        let habitCount: Int
        var id: String { name }
    }

    private let syncManager: SyncManager

    init(syncManager: SyncManager = .shared) {
        self.syncManager = syncManager
    }

    /// Alphabetically sorted categories with their habit counts.
    ///
    /// Categories aren't a stored entity — they only exist as the `category` string on habits — so the
    /// in-use set is derived from the habits themselves. Pass `including:` to also surface categories
    /// that have no habits yet (the built-in suggestions), which then report a count of 0.
    func summaries(for habits: [Habit], including alwaysShown: [String] = []) -> [CategorySummary] {
        let counts = Dictionary(grouping: habits.filter { !$0.category.isEmpty }, by: { $0.category })
            .mapValues(\.count)
        var names = Set(counts.keys)
        names.formUnion(alwaysShown.filter { !$0.isEmpty })
        return names
            .map { CategorySummary(name: $0, habitCount: counts[$0] ?? 0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    /// Renames a category across every habit that uses it. Renaming onto a name that already exists
    /// simply merges the two. No-ops on an empty or unchanged name; returns whether anything changed.
    @discardableResult
    func rename(_ oldName: String, to rawNewName: String, in habits: [Habit], context: ModelContext, syncsToServer: Bool) async -> Bool {
        let newName = rawNewName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newName.isEmpty, newName != oldName else { return false }
        return await apply(newCategory: newName, toHabitsIn: oldName, habits: habits, context: context, syncsToServer: syncsToServer)
    }

    /// Removes a category by clearing it from every habit that uses it. Habits are kept — they simply
    /// become uncategorized (shown under "Other" in the grid). Returns whether anything changed.
    @discardableResult
    func delete(_ name: String, in habits: [Habit], context: ModelContext, syncsToServer: Bool) async -> Bool {
        await apply(newCategory: "", toHabitsIn: name, habits: habits, context: context, syncsToServer: syncsToServer)
    }

    private func apply(newCategory: String, toHabitsIn oldName: String, habits: [Habit], context: ModelContext, syncsToServer: Bool) async -> Bool {
        let affected = habits.filter { $0.category == oldName }
        guard !affected.isEmpty else { return false }

        for habit in affected {
            habit.category = newCategory
            habit.updatedAt = .now
        }
        context.saveOrLog()

        if syncsToServer {
            await pushToServer(affected)
        }
        return true
    }

    /// Best-effort push of the changed habits to the server. Only synced habits are sent; if the
    /// request fails the local change still stands and the next full sync reconciles it.
    private func pushToServer(_ habits: [Habit]) async {
        let payloads = habits.filter { $0.isSyncable }.map { $0.toPayload }
        guard !payloads.isEmpty else { return }
        if case let .failure(error) = await syncManager.updateHabitsOnTheServer(with: payloads) {
            print("❌ Error: Failed to sync category change to the server: \(error.localizedDescription)")
        }
    }
}

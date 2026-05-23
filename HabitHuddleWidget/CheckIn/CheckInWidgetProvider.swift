//
//  CheckInWidgetProvider.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import WidgetKit

struct CheckInWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = HabitEntry
    typealias Intent = SelectHabitIntent

    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: .now, habit: .placeholder)
    }

    func snapshot(for configuration: SelectHabitIntent, in context: Context) async -> HabitEntry {
        HabitEntry(date: .now, habit: resolvedHabit(from: configuration) ?? .placeholder)
    }

    func timeline(for configuration: SelectHabitIntent, in context: Context) async -> Timeline<HabitEntry> {
        let entry = HabitEntry(date: .now, habit: resolvedHabit(from: configuration))
        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
        return Timeline(entries: [entry], policy: .after(nextMidnight))
    }

    private func resolvedHabit(from configuration: SelectHabitIntent) -> WidgetHabit? {
        let habits = WidgetDataStore.loadHabits()
        if let idString = configuration.habit?.id, let id = UUID(uuidString: idString) {
            return habits.first { $0.id == id }
        }
        return habits.first
    }
}

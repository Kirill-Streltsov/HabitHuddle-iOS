//
//  TodayWidgetProvider.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import WidgetKit

struct TodayWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = TodayEntry
    typealias Intent = SelectHabitsIntent

    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, habits: WidgetHabit.placeholders)
    }

    func snapshot(for configuration: SelectHabitsIntent, in context: Context) async -> TodayEntry {
        TodayEntry(date: .now, habits: resolvedHabits(from: configuration))
    }

    func timeline(for configuration: SelectHabitsIntent, in context: Context) async -> Timeline<TodayEntry> {
        let entry = TodayEntry(date: .now, habits: resolvedHabits(from: configuration))
        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
        return Timeline(entries: [entry], policy: .after(nextMidnight))
    }

    private func resolvedHabits(from configuration: SelectHabitsIntent) -> [WidgetHabit] {
        let all = WidgetDataStore.loadHabits()
        guard let selected = configuration.habits, !selected.isEmpty else { return all }
        let selectedIDs = Set(selected.map { $0.id })
        return all.filter { selectedIDs.contains($0.id.uuidString) }
    }
}

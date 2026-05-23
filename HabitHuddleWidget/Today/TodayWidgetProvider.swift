//
//  TodayWidgetProvider.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import WidgetKit

struct TodayWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, habits: WidgetHabit.placeholders)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(TodayEntry(date: .now, habits: WidgetDataStore.loadHabits()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let habits = WidgetDataStore.loadHabits()
        let entry = TodayEntry(date: .now, habits: habits)
        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

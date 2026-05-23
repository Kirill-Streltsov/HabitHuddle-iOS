//
//  WidgetUpdater.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import Foundation
import WidgetKit

enum WidgetUpdater {
    static func update(with habits: [Habit]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let widgetHabits: [WidgetHabit] = habits.map { habit in
            // oldest (index 0) to newest (index 6 = today)
            let last7 = (0 ..< 7).reversed().map { offset -> Bool in
                guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return false }
                return habit.checkIns.contains { calendar.isDate($0.date, inSameDayAs: day) }
            }
            return WidgetHabit(
                id: habit.id,
                name: habit.name,
                icon: habit.icon,
                category: habit.category,
                currentStreak: habit.currentStreak,
                isCheckedInToday: habit.isCheckedInToday,
                isSyncable: habit.isSyncable,
                completionPercentage: habit.completionPercentage,
                totalDays: habit.duration.numberOfDays,
                checkedInDays: habit.checkIns.count,
                last7Days: last7
            )
        }

        WidgetDataStore.saveHabits(widgetHabits)
        WidgetDataStore.saveToken(TokenManager.token)
        WidgetDataStore.saveBaseURL(Config.baseURL.absoluteString)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

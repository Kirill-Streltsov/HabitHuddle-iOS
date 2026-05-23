//
//  WidgetHabit.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import Foundation

struct WidgetHabit: Codable, Identifiable {
    let id: UUID
    let name: String
    let icon: String?
    let category: String
    var currentStreak: Int
    var isCheckedInToday: Bool
    let isSyncable: Bool
    let completionPercentage: Int
    let totalDays: Int
    let checkedInDays: Int
    // index 0 = Monday, index 6 = Sunday of the current week
    var last7Days: [Bool]
}

extension WidgetHabit {
    static var placeholder: WidgetHabit {
        // last7Days: Mon=0 … Sun=6 of current week
        WidgetHabit(
            id: UUID(),
            name: "Morning Run",
            icon: "figure.run",
            category: "Fitness",
            currentStreak: 5,
            isCheckedInToday: false,
            isSyncable: true,
            completionPercentage: 71,
            totalDays: 14,
            checkedInDays: 10,
            last7Days: [true, true, false, true, true, false, false]
        )
    }

    static var placeholders: [WidgetHabit] {
        [
            WidgetHabit(id: UUID(), name: "Morning Run", icon: "figure.run", category: "Fitness",
                        currentStreak: 5, isCheckedInToday: true, isSyncable: true,
                        completionPercentage: 71, totalDays: 14, checkedInDays: 10,
                        last7Days: [true, true, false, true, true, true, false]),
            WidgetHabit(id: UUID(), name: "Meditate", icon: "brain.head.profile", category: "Mindfulness",
                        currentStreak: 3, isCheckedInToday: false, isSyncable: true,
                        completionPercentage: 57, totalDays: 7, checkedInDays: 4,
                        last7Days: [false, true, true, false, true, false, false]),
            WidgetHabit(id: UUID(), name: "Drink Water", icon: "drop.fill", category: "Health",
                        currentStreak: 0, isCheckedInToday: false, isSyncable: false,
                        completionPercentage: 30, totalDays: 30, checkedInDays: 9,
                        last7Days: [false, false, true, false, false, false, false]),
        ]
    }
}

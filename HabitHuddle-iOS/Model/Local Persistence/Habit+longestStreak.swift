//
//  Habit+longestStreak.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 16.06.25.
//

import Foundation
extension Habit {
    var longestStreak: Int {
        // Simple example: count max consecutive days from checkIns dates (assume sorted)
        let dates = checkIns.map { Calendar.current.startOfDay(for: $0.date) }.sorted()
        guard !dates.isEmpty else { return 0 }

        var maxStreak = 1
        var currentStreak = 1

        for i in 1 ..< dates.count {
            let diff = Calendar.current.dateComponents([.day], from: dates[i - 1], to: dates[i]).day ?? 0
            if diff == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else if diff > 1 {
                currentStreak = 1
            }
        }
        return maxStreak
    }
}

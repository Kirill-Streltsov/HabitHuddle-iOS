//
//  Habit+currentStreak.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 09.06.25.
//

import Foundation
extension Habit {
    var currentStreak: Int? {
        let sortedCheckIns = checkIns.sorted { $0.date > $1.date }
        guard !sortedCheckIns.isEmpty else { return nil }

        var streak = 1
        var previousDate = Calendar.current.startOfDay(for: sortedCheckIns.first!.date)

        for checkIn in sortedCheckIns.dropFirst() {
            let currentDate = Calendar.current.startOfDay(for: checkIn.date)
            if Calendar.current.date(byAdding: .day, value: -1, to: previousDate) == currentDate {
                streak += 1
                previousDate = currentDate
            } else {
                break
            }
        }

        return streak
    }
}

//
//  HabitDTO+currentStreak.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 28.05.26.
//

import Foundation

extension HabitDTO {
    var currentStreak: Int {
        guard let checkIns, !checkIns.isEmpty else { return 0 }

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        let sortedCheckIns = checkIns.sorted { $0.date > $1.date }
        let mostRecentDay = cal.startOfDay(for: sortedCheckIns.first!.date)

        guard mostRecentDay == today || mostRecentDay == yesterday else { return 0 }

        var streak = 1
        var previousDate = mostRecentDay

        for checkIn in sortedCheckIns.dropFirst() {
            let currentDate = cal.startOfDay(for: checkIn.date)
            if currentDate == previousDate { continue }
            if cal.date(byAdding: .day, value: -1, to: previousDate) == currentDate {
                streak += 1
                previousDate = currentDate
            } else {
                break
            }
        }

        return streak
    }
}

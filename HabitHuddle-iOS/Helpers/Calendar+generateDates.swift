//
//  Calendar+generateDates.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 28.06.25.
//

import Foundation
extension Calendar {
    func generateDates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var current = startDate
        while current <= endDate {
            dates.append(current)
            current = date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }
}

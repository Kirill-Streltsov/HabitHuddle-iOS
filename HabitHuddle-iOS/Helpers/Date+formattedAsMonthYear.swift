//
//  Date+formattedAsMonthYear.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 03.06.25.
//

import Foundation

extension Date {
    func formattedAsMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }
}

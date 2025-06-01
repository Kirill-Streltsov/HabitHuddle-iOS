//
//  DateFormatter+longDate.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 30.05.25.
//

import Foundation

extension DateFormatter {
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        return formatter
    }()
}

extension Date {
    var longFormatted: String {
        DateFormatter.longDate.string(from: self)
    }

    var fullFormatted: String {
        DateFormatter.fullDate.string(from: self)
    }
}

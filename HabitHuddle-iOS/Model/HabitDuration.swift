//
//  HabitDuration.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 30.05.25.
//

import Foundation

enum HabitDuration: String, CaseIterable, Identifiable, Codable {
    case oneWeek
    case twoWeeks
    case oneMonth

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oneWeek: return String(localized: "1 Week")
        case .twoWeeks: return String(localized: "2 Weeks")
        case .oneMonth: return String(localized: "1 Month")
        }
    }

    var numberOfDays: Int {
        switch self {
        case .oneWeek: return 7
        case .twoWeeks: return 14
        case .oneMonth: return 30
        }
    }
}

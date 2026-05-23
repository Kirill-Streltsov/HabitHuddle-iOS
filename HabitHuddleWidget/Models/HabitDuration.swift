//
//  HabitDuration.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import Foundation

enum HabitDuration: String, CaseIterable, Identifiable, Codable {
    case oneWeek
    case twoWeeks
    case oneMonth

    var id: String { rawValue }

    var numberOfDays: Int {
        switch self {
        case .oneWeek: return 7
        case .twoWeeks: return 14
        case .oneMonth: return 30
        }
    }
}

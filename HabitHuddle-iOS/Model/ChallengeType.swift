//
//  ChallengeType.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import Foundation

enum ChallengeType: String, Codable {
    case competitive
    case supportive

    var displayName: String {
        switch self {
        case .competitive: return String(localized: "Competitive")
        case .supportive: return String(localized: "Supportive")
        }
    }
}

//
//  HabitPayload.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.25.
//

import Foundation

struct HabitPayload: Codable {
    let id: UUID
    let name: String
    let description: String?
    let isPublic: Bool
    let category: String?
    let icon: String?
    let duration: String
    let reminderTime: Date?
    let checkIns: [LightweightCheckIn]
    let challenges: [LightweightChallenge]
}

struct LightweightCheckIn: Codable {
    let id: UUID
    let date: Date
}

struct LightweightChallenge: Codable {
    let id: UUID
}

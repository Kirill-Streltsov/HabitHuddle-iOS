//
//  HabitPayload.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.25.
//

import Foundation

struct HabitPayload: Codable {
    let name: String
    let description: String?
    let frequency: String
    let reminderTime: Date?
}

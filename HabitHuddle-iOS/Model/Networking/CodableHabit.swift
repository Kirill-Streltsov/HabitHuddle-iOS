//
//  CodableHabit.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 21.05.25.
//

import Foundation

struct CodableHabit: Codable, Identifiable {
    let id: UUID
    let user: LightweightUser
    let name: String
    let description: String
    let frequency: HabitFrequency
    let reminderTime: Date?
    let createdAt: Date?
    let updatedAt: Date?
}

// Helping struct with id to help with decoding
struct LightweightUser: Identifiable, Codable {
    let id: UUID
}

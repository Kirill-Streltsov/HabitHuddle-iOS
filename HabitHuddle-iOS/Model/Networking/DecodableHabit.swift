//
//  DecodableHabit.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 21.05.25.
//

import Foundation

struct DecodableHabit: Identifiable, Decodable {
    let id: UUID
    let user: DecodableUser
    let name: String
    let description: String
    let frequency: HabitFrequency
    let reminderTime: Date?
    let createdAt: Date?
    let updatedAt: Date?
}

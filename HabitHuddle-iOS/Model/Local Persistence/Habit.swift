//
//  Habit.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import Foundation
import SwiftData

@Model
final class Habit: Identifiable {
    var id: UUID
    var user: LightweightUser
    var name: String
    var habitDescription: String
    var frequency: HabitFrequency
    var reminderTime: Date?
    var createdAt: Date?
    var updatedAt: Date?
    
    init(id: UUID, user: LightweightUser, name: String, description: String, frequency: HabitFrequency, reminderTime: Date? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.user = user
        self.name = name
        self.habitDescription = description
        self.frequency = frequency
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

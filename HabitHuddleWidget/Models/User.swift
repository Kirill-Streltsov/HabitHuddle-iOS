//
//  User.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import Foundation
import SwiftData

@Model
final class User: Identifiable {
    var id: UUID
    var habits: [Habit]?
    var username: String
    var name: String
    var createdAt: Date?
    var updatedAt: Date?

    init(id: UUID, username: String, name: String, createdAt: Date?, updatedAt: Date?, habits: [Habit] = []) {
        self.id = id
        self.username = username
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.habits = habits
    }
}

//
//  User.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
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

extension User {
    @MainActor static let sampleFriends: [User] = [
        User(
            id: UUID(),
            username: "mountain_goat",
            name: "Alice Johnson",
            createdAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 365 * 2), // 2 years ago
            updatedAt: nil
        ),
        User(
            id: UUID(),
            username: "pixelwizard",
            name: "Bruno Schmidt",
            createdAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 250),
            updatedAt: nil
        ),
        User(
            id: UUID(),
            username: "hiking_jane",
            name: "Jane Peterson",
            createdAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 100),
            updatedAt: nil
        ),
        User(
            id: UUID(),
            username: "coder_42",
            name: "Liam Garcia",
            createdAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 730), // ~2 years
            updatedAt: nil
        ),
        User(
            id: UUID(),
            username: "plantlover",
            name: "Olivia Davis",
            createdAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 45),
            updatedAt: nil
        )
    ]
}

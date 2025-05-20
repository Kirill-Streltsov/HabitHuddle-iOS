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
    var username: String
    var name: String
    var createdAt: Date?
    var updatedAt: Date?

    init(id: UUID, username: String, name: String, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.username = username
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

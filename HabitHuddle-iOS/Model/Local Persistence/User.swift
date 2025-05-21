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

// Create a preview container and context
extension ModelContainer {
    static var preview: ModelContainer = {
        do {
            // In-memory container for preview
            let container = try ModelContainer(for: User.self)
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}

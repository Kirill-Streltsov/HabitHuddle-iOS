//
//  HabitEntity.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import AppIntents

struct HabitEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Habit")
    static let defaultQuery = HabitEntityQuery()

    var id: String
    var name: String
    var icon: String?

    init(id: UUID, name: String, icon: String?) {
        self.id = id.uuidString
        self.name = name
        self.icon = icon
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

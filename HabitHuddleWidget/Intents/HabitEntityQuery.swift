//
//  HabitEntityQuery.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import AppIntents

struct HabitEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [HabitEntity] {
        WidgetDataStore.loadHabits()
            .filter { identifiers.contains($0.id.uuidString) }
            .map { HabitEntity(id: $0.id, name: $0.name, icon: $0.icon) }
    }

    func suggestedEntities() async throws -> [HabitEntity] {
        WidgetDataStore.loadHabits()
            .map { HabitEntity(id: $0.id, name: $0.name, icon: $0.icon) }
    }

    func defaultResult() async -> HabitEntity? {
        WidgetDataStore.loadHabits().first.map {
            HabitEntity(id: $0.id, name: $0.name, icon: $0.icon)
        }
    }
}

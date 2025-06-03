//
//  HabitStore.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 03.06.25.
//


import Foundation
import SwiftData

@ModelActor
actor HabitStore {
    func getPayload(for id: UUID) throws -> HabitPayload? {
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == id })
        guard let habit = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return HabitPayload(
            id: habit.id,
            name: habit.name,
            description: habit.habitDescription,
            duration: habit.duration.rawValue,
            reminderTime: habit.reminderTime,
            checkIns: habit.checkIns.map {
                LightweightCheckIn(id: $0.id, date: $0.date)
            }
        )
    }
}

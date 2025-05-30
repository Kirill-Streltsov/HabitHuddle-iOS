//
//  Habit.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import Foundation
import SwiftData

@Model
final class Habit: Identifiable, Hashable {
    var id: UUID
    var user: LightweightUser
    var name: String
    var habitDescription: String
    var duration: HabitDuration
    var reminderTime: Date?
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \HabitCheckIn.habit)
    var checkIns: [HabitCheckIn] = []

    init(
        id: UUID,
        user: LightweightUser,
        name: String,
        description: String,
        duration: HabitDuration,
        reminderTime: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.user = user
        self.name = name
        habitDescription = description
        self.duration = duration
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Habit {
    var isCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return checkIns.contains {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }

    func toggleCheckIn(in context: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)

        if let existingCheckIn = checkIns.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            context.delete(existingCheckIn)
        } else {
            let newCheckIn = HabitCheckIn(date: today, habit: self)
            checkIns.append(newCheckIn)
        }

        updatedAt = .now
        try? context.save()
    }
}

//
//  Habit.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import Foundation
import SwiftData

@Model
final class Habit: Identifiable, Hashable {
    var id: UUID
    var user: LightweightUser
    var name: String
    var habitDescription: String
    var isPublic: Bool
    var isSyncable: Bool
    var category: String
    var aiText: String?
    var icon: String?
    var duration: HabitDuration
    var reminderTime: Date?
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \HabitCheckIn.habit)
    var checkIns: [HabitCheckIn] = []
    @Relationship(deleteRule: .cascade, inverse: \Challenge.habit)
    var challenges: [Challenge] = []

    init(
        id: UUID,
        user: LightweightUser,
        name: String,
        description: String,
        isPublic: Bool = false,
        isSyncable: Bool = true,
        category: String = "",
        icon: String? = nil,
        aiText: String? = nil,
        duration: HabitDuration,
        reminderTime: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.user = user
        self.name = name
        self.habitDescription = description
        self.isPublic = isPublic
        self.isSyncable = isSyncable
        self.category = category
        self.icon = icon
        self.aiText = aiText
        self.duration = duration
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

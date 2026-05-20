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
        self.duration = duration
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: Creating a custom habit

extension Habit {
    static func createTestHabitsWithoutCheckIns() -> [Habit] {
        let namesDescriptionsCategories: [(String, String, String)] = [
            (String(localized: .meditate), String(localized: .practiceMeditationFor10MinutesDaily), String(localized: .mindfulness)),
            (String(localized: .digitalDetox), String(localized: .noSocialMediaAfter8Pm), String(localized: .productivity)),
            (String(localized: .dailyWalks), String(localized: .walkAtLeast10000StepsPerDay), String(localized: .fitness))
        ]
        
        func days(for duration: HabitDuration) -> Int {
            switch duration {
            case .oneWeek: return 7
            case .twoWeeks: return 14
            case .oneMonth: return 30
            }
        }

        var habits: [Habit] = []
        let calendar = Calendar.current
        let now = Date()

        for i in 0 ..< namesDescriptionsCategories.count {
            let (name, description, category) = namesDescriptionsCategories[i]
            let duration: HabitDuration = [.oneWeek, .twoWeeks, .oneMonth].randomElement()!

            // Random creation date up to 14 days ago
            guard let createdAt = calendar.date(byAdding: .day, value: -Int.random(in: 0 ..< 14), to: now) else { continue }

            let habit = Habit(
                id: UUID(),
                user: LightweightUser(id: UUID()),
                name: name,
                description: description,
                isPublic: false,
                category: category,
                duration: duration,
                reminderTime: calendar.date(bySettingHour: Int.random(in: 6 ... 22), minute: 0, second: 0, of: now)
            )
            habit.createdAt = createdAt
            habits.append(habit)
        }

        return habits
    }

    static func demoHabitWithRecentCheckIns() -> Habit {
        let calendar = Calendar.current
        let now = Date()
        let user = LightweightUser(id: UUID())

        let habit = Habit(
            id: UUID(),
            user: user,
            name: "Morning Meditation",
            description: "Take 10 minutes every morning to reset.",
            isPublic: false,
            icon: "brain.head.profile",
            duration: .twoWeeks,
            reminderTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now)!
        )

        habit.createdAt = calendar.date(byAdding: .day, value: -20, to: now)!

        let offsets: [Int] = [
            20, 18, 15, 12, 10, 8,
            5, 4, 3, 2, 1, 0,
        ]

        habit.checkIns = offsets.map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: now)!
            let checkInTime = calendar.date(bySettingHour: Int.random(in: 7 ... 9), minute: 0, second: 0, of: day)!
            return HabitCheckIn(date: checkInTime, habit: habit, habitID: habit.id)
        }

        return habit
    }

    static func demoHabitWithFullCheckIns() -> Habit {
        let calendar = Calendar.current
        let now = Date()
        let user = LightweightUser(id: UUID())

        let habit = Habit(
            id: UUID(),
            user: user,
            name: "Workout",
            description: "Full 90-day workout challenge!",
            isPublic: false,
            duration: .oneMonth, // Just for display
            reminderTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
        )

        habit.createdAt = calendar.date(byAdding: .day, value: -90, to: now)!

        let offsets: [Int] = [
            0, 1, 2, 3, 5, 6, 7, 9, 10, 12, 14, 16, 18, 20, 21, 22,
            24, 26, 27, 28, 30, 32, 34, 36, 38, 39, 40, 41, 42, 44, 46, 48, 49, 50,
            52, 54, 55, 56, 58, 60, 62, 65, 67, 70, 72, 73, 75, 78, 81, 84, 87, 89,
            -1, -2, -3, -4, -5, -6
        ]

        habit.checkIns = offsets.map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: now)!
            let checkInTime = calendar.date(bySettingHour: Int.random(in: 7 ... 22), minute: 0, second: 0, of: day)!
            return HabitCheckIn(date: checkInTime, habit: habit, habitID: habit.id)
        }

        return habit
    }
    
}

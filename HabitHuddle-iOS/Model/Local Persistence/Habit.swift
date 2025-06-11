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
    @Relationship(deleteRule: .cascade, inverse: \Challenge.habit)
    var challenges: [Challenge] = []

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

// MARK: Creating a custom habit

extension Habit {
    static func createTestHabitsWithCheckIns() -> [Habit] {
        let namesAndDescriptions: [(String, String)] = [
            ("Morning Run", "Go for a run every morning before 8 AM"),
            ("Meditate", "Practice meditation for 10 minutes daily"),
            ("Drink Water", "Drink at least 2 liters of water per day"),
            ("Write Journal", "Write a daily journal entry before bed"),
            ("Stretching", "Stretch for 5 minutes after waking up"),
            ("Learn German", "Practice German vocabulary daily"),
            ("Code Practice", "Solve 1 coding problem every day"),
            ("No Sugar", "Avoid all sugary foods for a month"),
            ("Gratitude List", "Write 3 things you're grateful for"),
            ("Sleep by 11", "Go to bed before 11 PM"),
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

        for i in 0 ..< namesAndDescriptions.count {
            let (name, description) = namesAndDescriptions[i]
            let duration: HabitDuration = [.oneWeek, .twoWeeks, .oneMonth].randomElement()!
            let numberOfDays = days(for: duration)

            // Random creation date up to 14 days ago
            guard let createdAt = calendar.date(byAdding: .day, value: -Int.random(in: 0 ..< 14), to: now) else { continue }

            // Compute end date
            guard let endDate = calendar.date(byAdding: .day, value: numberOfDays - 1, to: createdAt) else { continue }

            let habit = Habit(
                id: UUID(),
                user: LightweightUser(id: UUID()),
                name: name,
                description: description,
                duration: duration,
                reminderTime: calendar.date(bySettingHour: Int.random(in: 6 ... 22), minute: 0, second: 0, of: now)
            )
            habit.createdAt = createdAt

            // Build all valid dates between createdAt and endDate (inclusive)
            var checkIns: [HabitCheckIn] = []
            var currentDate = createdAt
            while currentDate <= endDate {
                if Bool.random() {
                    // Random time during the day
                    if let checkInTime = calendar.date(
                        bySettingHour: Int.random(in: 6 ... 23),
                        minute: Int.random(in: 0 ..< 60),
                        second: Int.random(in: 0 ..< 60),
                        of: currentDate
                    ) {
                        checkIns.append(HabitCheckIn(date: checkInTime, habit: habit))
                    }
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }

            habit.checkIns = checkIns
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
            duration: .twoWeeks,
            reminderTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now)!
        )

        habit.createdAt = calendar.date(byAdding: .day, value: -20, to: now)!

        // Check-in days (relative to today), including a recent 6-day streak
        let offsets: [Int] = [
            20, 18, 15, 12, 10, 8, // earlier scattered
            5, 4, 3, 2, 1, 0, // recent streak!
        ]

        habit.checkIns = offsets.map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: now)!
            let checkInTime = calendar.date(bySettingHour: Int.random(in: 7 ... 9), minute: 0, second: 0, of: day)!
            return HabitCheckIn(date: checkInTime, habit: habit)
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
            duration: .oneMonth, // Just for display
            reminderTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
        )

        habit.createdAt = calendar.date(byAdding: .day, value: -90, to: now)!

        let offsets: [Int] = [
            0, 1, 2, 3, 5, 6, 7, 9, 10, 12, 14, 16, 18, 20, 21, 22,
            24, 26, 27, 28, 30, 32, 34, 36, 38, 39, 40, 41, 42, 44, 46, 48, 49, 50,
            52, 54, 55, 56, 58, 60, 62, 65, 67, 70, 72, 73, 75, 78, 81, 84, 87, 89,
            -1, -3, -5, -6
        ]

        habit.checkIns = offsets.map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: now)!
            let checkInTime = calendar.date(bySettingHour: Int.random(in: 7 ... 22), minute: 0, second: 0, of: day)!
            return HabitCheckIn(date: checkInTime, habit: habit)
        }

        return habit
    }
}

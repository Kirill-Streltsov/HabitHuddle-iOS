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
        self.icon = icon
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
            ("Read Books", "Read at least 10 pages of a book each day"),
            ("Digital Detox", "No social media after 8 PM"),
            ("Walk 10k Steps", "Walk at least 10,000 steps per day"),
            ("Budget Tracking", "Log your spending at the end of each day"),
            ("Cold Showers", "Take a cold shower each morning"),
            ("Compliment Someone", "Give a genuine compliment to someone each day"),
            ("Learn Guitar", "Practice guitar for 15 minutes daily"),
            ("Meal Prep", "Prepare your meals for the next day"),
            ("Declutter", "Organize or clean one small area daily"),
            ("Pomodoro Focus", "Complete at least 1 Pomodoro (25 min focus) session"),
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
                        checkIns.append(HabitCheckIn(date: checkInTime, habit: habit, habitID: habit.id))
                    }
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }

            habit.checkIns = checkIns
            habits.append(habit)
        }

        return habits
    }
    
    static func createTestHabitsWithoutCheckIns() -> [Habit] {
        let namesAndDescriptions: [(String, String)] = [
            ("Read Books", "Read at least 10 pages of a book each day"),
            ("Digital Detox", "No social media after 8 PM"),
            ("Walk 10k Steps", "Walk at least 10,000 steps per day"),
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

            // Random creation date up to 14 days ago
            guard let createdAt = calendar.date(byAdding: .day, value: -Int.random(in: 0 ..< 14), to: now) else { continue }

            let habit = Habit(
                id: UUID(),
                user: LightweightUser(id: UUID()),
                name: name,
                description: description,
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
    
    static func demoHabitWith13Of14CheckIns() -> Habit {
        let calendar = Calendar.current
        let now = Date()
        let user = LightweightUser(id: UUID())

        // Create a habit with a 14-day duration
        let habit = Habit(
            id: UUID(),
            user: user,
            name: "Read a Book",
            description: "Read at least 10 pages every day.",
            duration: .twoWeeks,
            reminderTime: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now)!
        )

        // Set creation date to 13 days ago (14-day habit: today included)
        habit.createdAt = calendar.date(byAdding: .day, value: -13, to: now)!

        // Create check-ins from 13 days ago up to **yesterday**
        var checkIns: [HabitCheckIn] = []
        for offset in (1...13).reversed() { // Skip offset 0 (today)
            if let checkInDate = calendar.date(byAdding: .day, value: -offset, to: now),
               let checkInTime = calendar.date(bySettingHour: Int.random(in: 7...10), minute: Int.random(in: 0..<60), second: 0, of: checkInDate) {
                checkIns.append(HabitCheckIn(date: checkInTime, habit: habit, habitID: habit.id))
            }
        }

        habit.checkIns = checkIns
        return habit
    }
}

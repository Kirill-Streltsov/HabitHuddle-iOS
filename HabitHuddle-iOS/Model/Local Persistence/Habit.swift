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

// MARK: Checking in for today
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
            ("Sleep by 11", "Go to bed before 11 PM")
        ]

        func days(for duration: HabitDuration) -> Int {
            switch duration {
            case .oneWeek: return 7
            case .twoWeeks: return 14
            case .oneMonth: return 30
            }
        }

        var habits: [Habit] = []

        for i in 0..<namesAndDescriptions.count {
            let (name, description) = namesAndDescriptions[i]
            let duration: HabitDuration = [.oneWeek, .twoWeeks, .oneMonth].randomElement()!
            let numberOfDays = days(for: duration)

            // Random start date within the last 2 weeks
            let calendar = Calendar.current
            let now = Date()
            let randomOffset = Int.random(in: 0..<14)
            guard let createdAt = calendar.date(byAdding: .day, value: -randomOffset, to: now) else { continue }

            let habit = Habit(
                id: UUID(),
                user: LightweightUser(id: UUID()),
                name: name,
                description: description,
                duration: duration,
                reminderTime: calendar.date(bySettingHour: Int.random(in: 6...22), minute: 0, second: 0, of: now)
            )
            habit.createdAt = createdAt

            // Calculate valid date range
            let endDate = calendar.date(byAdding: .day, value: numberOfDays - 1, to: createdAt)!

            // Simulate some check-ins within that valid range
            var checkIns: [HabitCheckIn] = []
            for dayOffset in 0..<numberOfDays {
                let date = calendar.date(byAdding: .day, value: dayOffset, to: createdAt)!
                if Bool.random() { // 50% chance the user checked in
                    let checkInTime = calendar.date(
                        bySettingHour: Int.random(in: 6...23),
                        minute: Int.random(in: 0..<60),
                        second: Int.random(in: 0..<60),
                        of: date
                    )!
                    checkIns.append(HabitCheckIn(date: checkInTime, habit: habit))
                }
            }

            habit.checkIns = checkIns
            habits.append(habit)
        }

        return habits
    }
}

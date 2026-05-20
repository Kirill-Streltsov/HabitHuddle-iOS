//
//  Habit+Preview.swift
//  HabitHuddle-iOS
//

import Foundation

#if DEBUG
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

            guard let createdAt = calendar.date(byAdding: .day, value: -Int.random(in: 0 ..< 14), to: now) else { continue }
            guard let endDate = calendar.date(byAdding: .day, value: numberOfDays - 1, to: createdAt) else { continue }

            let habit = Habit(
                id: UUID(),
                user: LightweightUser(id: UUID()),
                name: name,
                description: description,
                isPublic: false,
                duration: duration,
                reminderTime: calendar.date(bySettingHour: Int.random(in: 6 ... 22), minute: 0, second: 0, of: now)
            )
            habit.createdAt = createdAt

            var checkIns: [HabitCheckIn] = []
            var currentDate = createdAt
            while currentDate <= endDate {
                if Bool.random(),
                   let checkInTime = calendar.date(
                       bySettingHour: Int.random(in: 6 ... 23),
                       minute: Int.random(in: 0 ..< 60),
                       second: Int.random(in: 0 ..< 60),
                       of: currentDate
                   ) {
                    checkIns.append(HabitCheckIn(date: checkInTime, habit: habit, habitID: habit.id))
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }

            habit.checkIns = checkIns
            habits.append(habit)
        }

        return habits
    }

    static func demoHabitWith13Of14CheckIns() -> Habit {
        let calendar = Calendar.current
        let now = Date()

        let habit = Habit(
            id: UUID(),
            user: LightweightUser(id: UUID()),
            name: "Read a Book",
            description: "Read at least 10 pages every day.",
            isPublic: false,
            duration: .twoWeeks,
            reminderTime: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now)!
        )
        habit.createdAt = calendar.date(byAdding: .day, value: -13, to: now)!

        var checkIns: [HabitCheckIn] = []
        for offset in (1 ... 13).reversed() {
            if let checkInDate = calendar.date(byAdding: .day, value: -offset, to: now),
               let checkInTime = calendar.date(bySettingHour: Int.random(in: 7 ... 10), minute: Int.random(in: 0 ..< 60), second: 0, of: checkInDate) {
                checkIns.append(HabitCheckIn(date: checkInTime, habit: habit, habitID: habit.id))
            }
        }

        habit.checkIns = checkIns
        return habit
    }

    static func demoHabitWith25Of14CheckIns() -> Habit {
        let calendar = Calendar.current
        let now = Date()

        let habit = Habit(
            id: UUID(),
            user: LightweightUser(id: UUID()),
            name: "Read a Book",
            description: "Read at least 10 pages every day.",
            isPublic: false,
            duration: .twoWeeks,
            reminderTime: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now)!
        )
        habit.createdAt = calendar.date(byAdding: .day, value: -13, to: now)!

        var checkIns: [HabitCheckIn] = []
        for dayOffset in stride(from: 13, through: 0, by: -1) {
            guard let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let countForDay = Int.random(in: 1 ... 3)
            for _ in 0 ..< countForDay {
                guard checkIns.count < 25 else { break }
                if let time = calendar.date(bySettingHour: Int.random(in: 7 ... 22), minute: Int.random(in: 0 ..< 60), second: 0, of: dayDate) {
                    checkIns.append(HabitCheckIn(date: time, habit: habit, habitID: habit.id))
                }
            }
            if checkIns.count >= 25 { break }
        }

        habit.checkIns = checkIns
        return habit
    }
}
#endif

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
    static func createTestHabitWithCheckIns() -> Habit {
        
        
        let habit = Habit(
            id: UUID(),
            user: LightweightUser(id: UUID()),
            name: "Read Books",
            description: "Read at least 20 pages every day",
            duration: .oneMonth,
            reminderTime: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now)
        )
        
        let calendar = Calendar.current
        let now = Date()
        
        let maxCount = 15
        
        var uniqueDates: [Date] = []
        var usedDays = Set<String>() // To track day components like "yyyy-MM-dd"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        while uniqueDates.count < maxCount {
            // Random day offset 0 to 29 days ago
            let randomDayOffset = Int.random(in: 0..<30)
            let randomHour = Int.random(in: 0..<24)
            let randomMinute = Int.random(in: 0..<60)
            let randomSecond = Int.random(in: 0..<60)
            
            guard let randomDateBase = calendar.date(byAdding: .day, value: -randomDayOffset, to: now),
                  let randomDate = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: randomSecond, of: randomDateBase)
            else {
                continue
            }
            
            let dayString = dateFormatter.string(from: randomDate)
            
            // Check if day already used
            if !usedDays.contains(dayString) {
                usedDays.insert(dayString)
                uniqueDates.append(randomDate)
            }
        }
        
        var checkIns: [HabitCheckIn] = []
        for i in 0..<maxCount {
            checkIns.append(HabitCheckIn(date: uniqueDates[i], habit: habit))
        }
        habit.checkIns = checkIns
        
        return habit
    }
}

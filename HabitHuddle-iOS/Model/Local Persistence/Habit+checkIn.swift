//
//  Habit+checkIn.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import Foundation
import SwiftData

// MARK: Checking in for today

extension Habit {
    var isCheckedInToday: Bool {
        let utcCalendar = Calendar(identifier: .gregorian)
        var utc = utcCalendar
        utc.timeZone = TimeZone(secondsFromGMT: 0)!
        let todayUTC = utc.startOfDay(for: Date())
        
        return checkIns.contains {
            utc.isDate($0.date, inSameDayAs: todayUTC)
        }
    }
    
    func toggleCheckIn(in context: ModelContext) {
        let utcCalendar = Calendar(identifier: .gregorian)
        var utc = utcCalendar
        utc.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = Date()
        
        if let existing = checkIns.first(where: { utc.isDate($0.date, inSameDayAs: now) }) {
            context.delete(existing)
        } else {
            let newCheckIn = HabitCheckIn(date: now, habit: self)
            checkIns.append(newCheckIn)
        }
        
        updatedAt = .now
        try? context.save()
        toggleCheckInRemotely()
    }

    func toggleCheckInRemotely() {
        Task {
            do {
                _ = try await NetworkManager.shared.requestStatusCode(
                    endpoint: .checkIntoHabit(with: id),
                    method: .post
                )
                print("✅ Checked into habit from the HomeView: \(self.name)")
            } catch {
                print("❌ Error: Could not check into habit from the HomeView: \(self.name)")
            }
        }
    }
}

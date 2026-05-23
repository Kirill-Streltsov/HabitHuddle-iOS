//
//  Habit+checkIn.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import Foundation
import SwiftData
import WidgetKit
@preconcurrency import UserNotifications

// MARK: Checking in for today

extension Habit {
    var isCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        
        return checkIns.contains {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
    
    func toggleCheckIn(in context: ModelContext) {
        let now = Date()
        if let existing = checkIns.first(where: { Calendar.current.isDate($0.date, inSameDayAs: now) }) {
            context.delete(existing)
        } else {
            let newCheckIn = HabitCheckIn(date: now, habit: self, habitID: self.id)
            checkIns.append(newCheckIn)
            cancelTodaysNotification()
        }
        
        updatedAt = .now
        context.saveOrLog()
        toggleCheckInRemotely()
        WidgetDataStore.updateCheckInState(habitID: id, isCheckedIn: isCheckedInToday)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func toggleCheckInRemotely() {
        let habitID = id
        let habitName = name
        Task {
            do {
                _ = try await NetworkManager.shared.requestStatusCode(
                    endpoint: .checkIntoHabit(with: habitID),
                    method: .post
                )
                print("✅ Checked into habit from the HomeView: \(habitName)")
            } catch {
                print("❌ Error: Could not check into habit from the HomeView: \(habitName)")
            }
        }
    }
    
    func cancelTodaysNotification() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        let identifier = "habit_\(id)_\(todayString)"
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled today's notification for \(name)")
    }
    
    func cancelHabitNotification() {
        let identifier = "habit_\(self.id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notification cancelled for \(self.name)")
    }
}

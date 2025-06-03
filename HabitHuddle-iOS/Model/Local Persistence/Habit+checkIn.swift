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
        let today = Calendar.current.startOfDay(for: .now)
        return checkIns.contains {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }

    func toggleCheckIn(in context: ModelContext) {
        let calendar = Calendar.current
        let finishDate = calendar.date(byAdding: .day, value: self.duration.numberOfDays, to: self.createdAt)
        let today = calendar.startOfDay(for: .now)
        
        if let finish = finishDate, today <= finish {
            if let existingCheckIn = checkIns.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                context.delete(existingCheckIn)
            } else {
                let newCheckIn = HabitCheckIn(date: today, habit: self)
                checkIns.append(newCheckIn)
            }
            updatedAt = .now
            try? context.save()
            toggleCheckInRemotely()
        }
    }

    func toggleCheckInRemotely() {
        Task {
            do {
                _ = try await NetworkingManager.shared.requestStatusCode(
                    endpoint: .checkIntoHabit(with: id),
                    method: .post
                )
                print("✅ Checked into habit from the HomeView: \(self.name)")
            } catch {
                SyncManager.shared.add(SyncOperation(habitID: id, action: .update))
                print("❌ Could not check into habit from the HomeView: \(self.name)")
            }
        }
    }
}

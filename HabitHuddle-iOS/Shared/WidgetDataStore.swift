//
//  WidgetDataStore.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import Foundation

enum WidgetDataStore {
    static let appGroupID = "group.com.krlsrlsv.HabitHuddle-iOS"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: Habits

    static func saveHabits(_ habits: [WidgetHabit]) {
        guard let data = try? JSONEncoder().encode(habits) else { return }
        defaults?.set(data, forKey: "widgetHabits")
    }

    static func loadHabits() -> [WidgetHabit] {
        guard let data = defaults?.data(forKey: "widgetHabits"),
              let habits = try? JSONDecoder().decode([WidgetHabit].self, from: data)
        else { return [] }
        return habits
    }

    // MARK: Auth token

    static func saveToken(_ token: String?) {
        defaults?.set(token, forKey: "widgetToken")
    }

    static func loadToken() -> String? {
        defaults?.string(forKey: "widgetToken")
    }

    // MARK: Base URL

    static func saveBaseURL(_ url: String) {
        defaults?.set(url, forKey: "widgetBaseURL")
    }

    static func loadBaseURL() -> String {
        defaults?.string(forKey: "widgetBaseURL") ?? "https://habithuddle-backend.onrender.com/api/"
    }

    // MARK: Optimistic updates from widget intent

    static func markCheckedIn(habitID: UUID) {
        // 1=Sun, 2=Mon … 7=Sat → convert to Mon-first index (Mon=0, …, Sun=6)
        let weekday = Calendar.current.component(.weekday, from: Date())
        let todayIndex = (weekday + 5) % 7

        var habits = loadHabits()
        for i in habits.indices where habits[i].id == habitID {
            guard !habits[i].isCheckedInToday else { return }
            habits[i].isCheckedInToday = true
            habits[i].currentStreak += 1
            if todayIndex < habits[i].last7Days.count {
                habits[i].last7Days[todayIndex] = true
            }
        }
        saveHabits(habits)
    }

    static func updateCheckInState(habitID: UUID, isCheckedIn: Bool) {
        // 1=Sun, 2=Mon … 7=Sat → convert to Mon-first index (Mon=0, …, Sun=6)
        let weekday = Calendar.current.component(.weekday, from: Date())
        let todayIndex = (weekday + 5) % 7

        var habits = loadHabits()
        for i in habits.indices where habits[i].id == habitID {
            if isCheckedIn && !habits[i].isCheckedInToday {
                habits[i].isCheckedInToday = true
                habits[i].currentStreak += 1
            } else if !isCheckedIn && habits[i].isCheckedInToday {
                habits[i].isCheckedInToday = false
                habits[i].currentStreak = max(0, habits[i].currentStreak - 1)
            }
            if todayIndex < habits[i].last7Days.count {
                habits[i].last7Days[todayIndex] = isCheckedIn
            }
        }
        saveHabits(habits)
    }

    // MARK: Pending check-ins (widget → server sync)

    static func addPendingCheckIn(habitID: UUID) {
        var ids = loadPendingCheckInIDs()
        ids.insert(habitID.uuidString)
        defaults?.set(Array(ids), forKey: "pendingCheckInIDs")
    }

    static func removePendingCheckIn(habitID: UUID) {
        var ids = loadPendingCheckInIDs()
        ids.remove(habitID.uuidString)
        defaults?.set(Array(ids), forKey: "pendingCheckInIDs")
    }

    static func loadPendingCheckInIDs() -> Set<String> {
        let array = defaults?.stringArray(forKey: "pendingCheckInIDs") ?? []
        return Set(array)
    }
}

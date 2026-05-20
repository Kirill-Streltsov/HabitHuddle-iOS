//
//  NotificationGenerator.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 06.07.25.
//

import Foundation

struct HabitNotification {
    let title: String
    let subtitle: String
    let body: String
}

struct NotificationGenerator {
    static func randomNotification(for habitName: String) -> HabitNotification {
        let templates: [HabitNotification] = [
            HabitNotification(
                title: String(localized: "✅ Stay on Track!"),
                subtitle: String(localized: "Your habit needs you today."),
                body: String(localized: "Don’t forget to check in for \u{201C}\(habitName)\u{201D}! Small steps lead to big changes.")
            ),
            HabitNotification(
                title: String(localized: "🌅 New Day, New Win!"),
                subtitle: String(localized: "Time to build momentum."),
                body: String(localized: "Start your day strong with \u{201C}\(habitName)\u{201D}. You’ve got this!")
            ),
            HabitNotification(
                title: String(localized: "📈 Tiny Habits. Big Results."),
                subtitle: String(localized: "Your future self is watching."),
                body: String(localized: "You’re just one check-in away from progress. Let’s crush \u{201C}\(habitName)\u{201D} today!")
            ),
            HabitNotification(
                title: String(localized: "⏰ It’s Habit O’Clock!"),
                subtitle: String(localized: "Stay consistent, stay strong."),
                body: String(localized: "Now’s the perfect time to complete \u{201C}\(habitName)\u{201D}. Keep the streak alive!")
            )
        ]

        return templates.randomElement() ?? templates[0]
    }
}

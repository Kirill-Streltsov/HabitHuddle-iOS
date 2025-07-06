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
                title: "✅ Stay on Track!",
                subtitle: "Your habit needs you today.",
                body: "Don’t forget to check in for “\(habitName)”! Small steps lead to big changes."
            ),
            HabitNotification(
                title: "🌅 New Day, New Win!",
                subtitle: "Time to build momentum.",
                body: "Start your day strong with “\(habitName)”. You’ve got this!"
            ),
            HabitNotification(
                title: "📈 Tiny Habits. Big Results.",
                subtitle: "Your future self is watching.",
                body: "You’re just one check-in away from progress. Let’s crush “\(habitName)” today!"
            ),
            HabitNotification(
                title: "⏰ It’s Habit O’Clock!",
                subtitle: "Stay consistent, stay strong.",
                body: "Now’s the perfect time to complete “\(habitName)”. Keep the streak alive!"
            )
        ]
        
        return templates.randomElement() ?? templates[0]
    }
}

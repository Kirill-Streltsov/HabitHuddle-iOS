//
//  Habit+toPayload.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 09.06.25.
//

import Foundation

extension Habit {
    var toPayload: HabitPayload {
        HabitPayload(
            id: id,
            name: name,
            description: habitDescription,
            isPublic: isPublic,
            category: category,
            icon: icon,
            duration: duration.rawValue,
            reminderTime: reminderTime,
            checkIns: checkIns.map { LightweightCheckIn(id: $0.id, date: $0.date) },
            challenges: []
        )
    }
}

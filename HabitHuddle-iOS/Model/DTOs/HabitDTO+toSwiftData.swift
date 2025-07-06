//
//  HabitDTO+saveLocally.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 09.06.25.
//

import Foundation
import SwiftData

extension HabitDTO {
    func saved(in context: ModelContext) -> Habit {
        let habit = Habit(
            id: self.id,
            user: LightweightUser(id: user.id),
            name: self.name,
            description: self.description,
            isSyncable: true,
            category: self.category,
            icon: self.icon,
            duration: self.duration,
            reminderTime: self.reminderTime)
        
        context.insert(habit)
        
        if let checkIns = self.checkIns, !checkIns.isEmpty {
            for checkIn in checkIns {
                let checkInToSave = HabitCheckIn(
                    id: checkIn.id,
                    date: checkIn.date,
                    habit: habit,
                    habitID: habit.id
                )
                context.insert(checkInToSave)
            }
        }
        return habit
    }
}

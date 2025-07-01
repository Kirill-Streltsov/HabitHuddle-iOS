//
//  HabitDTO+toSwiftData.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 09.06.25.
//

import Foundation

extension HabitDTO {
    func toSwiftData() -> Habit {
        let habit = Habit(
            id: self.id,
            user: LightweightUser(id: user.id),
            name: self.name,
            description: self.description,
            category: self.category,
            icon: self.icon,
            duration: self.duration)
        
        if let checkIns = self.checkIns, !checkIns.isEmpty {
            for checkIn in checkIns {
                let checkInToSave = HabitCheckIn(id: checkIn.id, date: checkIn.date, habit: habit, habitID: habit.id)
                habit.checkIns.append(checkInToSave)
            }
        }
        return habit
    }
}

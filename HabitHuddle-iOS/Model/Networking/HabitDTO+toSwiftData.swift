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
            id: id,
            user: LightweightUser(id: user.id),
            name: name,
            description: description,
            duration: duration)
        
        if let checkIns = checkIns, !checkIns.isEmpty {
            for checkIn in checkIns {
                let checkInToSave = HabitCheckIn(id: checkIn.id, date: checkIn.date, habit: habit)
                habit.checkIns.append(checkInToSave)
            }
        }
        return habit
    }
}

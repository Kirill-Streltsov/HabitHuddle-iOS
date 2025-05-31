//
//  CodableHabitCheckIn.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 31.05.25.
//

import Foundation

struct CodableHabitCheckIn: Codable, Identifiable {
    var id: UUID
    var date: Date
    var habit: LightweightHabit

    init(id: UUID = .init(), date: Date = .now, habit: LightweightHabit) {
        self.id = id
        self.date = date
        self.habit = habit
    }
}

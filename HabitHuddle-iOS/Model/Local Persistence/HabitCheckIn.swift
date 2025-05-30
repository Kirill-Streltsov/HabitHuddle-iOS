//
//  HabitCheckIn.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 30.05.25.
//

import Foundation
import SwiftData

@Model
final class HabitCheckIn: Identifiable, Hashable {
    var id: UUID
    var date: Date
    var habit: Habit

    init(id: UUID = .init(), date: Date = .now, habit: Habit) {
        self.id = id
        self.date = date
        self.habit = habit
    }
}

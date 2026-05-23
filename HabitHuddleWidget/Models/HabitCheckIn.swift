//
//  HabitCheckIn.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import Foundation
import SwiftData

@Model
final class HabitCheckIn: Identifiable, Hashable {
    var id: UUID
    var date: Date
    var habit: Habit?
    var habitID: UUID

    init(id: UUID = .init(), date: Date = .now, habit: Habit, habitID: UUID) {
        self.id = id
        self.date = date
        self.habit = habit
        self.habitID = habitID
    }
}

//
//  Habit+isCompleted.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.06.25.
//

import Foundation
extension Habit {
    var isCompleted: Bool {
        checkIns.count >= duration.numberOfDays
    }
    
    var isFullyCompletedButNotToday: Bool {
        isCompleted && !isCheckedInToday
    }
}

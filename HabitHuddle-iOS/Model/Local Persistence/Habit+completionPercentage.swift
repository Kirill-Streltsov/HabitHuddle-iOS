//
//  Habit+completionPercentage.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 16.06.25.
//

import Foundation
extension Habit {
    var completionPercentage: Int {
        let completionPercentageDouble = Double(checkIns.count) / Double(duration.numberOfDays)
        return min(100, Int(completionPercentageDouble * 100))
    }
}

//
//  HabitDTO+isCompleted.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 06.07.25.
//

import Foundation
extension HabitDTO {
    var isCompleted: Bool {
        guard let checkIns = checkIns else { return false }
        return checkIns.count >= duration.numberOfDays
    }
}

//
//  HabitDTO+completionPercentage.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 06.07.25.
//

import Foundation
extension HabitDTO {
    var completionPercentage: Int {
        guard let checkIns = checkIns else { return 0 }
        let completionPercentageDouble = Double(checkIns.count) / Double(duration.numberOfDays)
        return Int(completionPercentageDouble * 100)
    }
}

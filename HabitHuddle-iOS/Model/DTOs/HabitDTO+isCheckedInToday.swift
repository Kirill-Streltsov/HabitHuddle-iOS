//
//  HabitDTO+isCheckedInToday.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 06.07.25.
//

import Foundation
extension HabitDTO {
    var isCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        
        guard let checkIns = checkIns else { return false }
        return checkIns.contains {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
}

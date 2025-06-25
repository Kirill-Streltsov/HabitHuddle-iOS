//
//  Date+minute.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.06.25.
//

import Foundation
extension Date {
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
}

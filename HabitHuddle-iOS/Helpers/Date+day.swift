//
//  Date+day.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.06.25.
//

import Foundation
extension Date {
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
}

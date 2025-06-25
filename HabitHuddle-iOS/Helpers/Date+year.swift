//
//  Date+year.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.06.25.
//

import Foundation
extension Date {
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
}

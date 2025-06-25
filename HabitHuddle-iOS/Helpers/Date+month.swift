//
//  Date+month.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.06.25.
//

import Foundation
extension Date {
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
}

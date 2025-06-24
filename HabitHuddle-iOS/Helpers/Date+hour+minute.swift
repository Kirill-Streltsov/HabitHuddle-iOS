//
//  Date+hour+minute.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 24.06.25.
//

import Foundation
extension Date {
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
}

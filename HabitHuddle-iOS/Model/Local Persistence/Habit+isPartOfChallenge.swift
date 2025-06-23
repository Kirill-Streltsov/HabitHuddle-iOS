//
//  Habit+isPartOfChallenge.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.06.25.
//

import Foundation
extension Habit {
    var isPartOfChallenge: Bool {
        if !challenges.isEmpty {
            return true
        } else {
            return false
        }
    }
}

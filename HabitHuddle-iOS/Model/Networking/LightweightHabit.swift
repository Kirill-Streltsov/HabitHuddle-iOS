//
//  LightweightHabit.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 31.05.25.
//

import Foundation

// Helping struct with id to help with decoding
struct LightweightHabit: Identifiable, Codable {
    let id: UUID
}

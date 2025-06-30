//
//  CodableHabit.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 21.05.25.
//

import Foundation

struct HabitDTO: Codable, Identifiable {
    var id: UUID
    let user: LightweightUser
    let name: String
    let description: String
    let goal: String
    let duration: HabitDuration
    let reminderTime: Date?
    let createdAt: Date?
    let updatedAt: Date?
    let checkIns: [HabitCheckInDTO]?
    let challenges: [ChallengeDTO]?
    let icon: String?
}

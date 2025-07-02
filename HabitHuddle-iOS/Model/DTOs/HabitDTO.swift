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
    let isPublic: Bool
    let category: String
    let duration: HabitDuration
    let reminderTime: Date?
    let createdAt: Date?
    let updatedAt: Date?
    let checkIns: [HabitCheckInDTO]?
    let challenges: [ChallengeDTO]?
    let icon: String?
    
    init(id: UUID, user: LightweightUser, name: String, description: String, isPublic: Bool = false, category: String, duration: HabitDuration, reminderTime: Date?, createdAt: Date?, updatedAt: Date?, checkIns: [HabitCheckInDTO]?, challenges: [ChallengeDTO]?, icon: String?) {
        self.id = id
        self.user = user
        self.name = name
        self.description = description
        self.isPublic = isPublic
        self.category = category
        self.duration = duration
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.checkIns = checkIns
        self.challenges = challenges
        self.icon = icon
    }
}

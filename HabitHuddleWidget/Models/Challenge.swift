//
//  Challenge.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import Foundation
import SwiftData

@Model
final class Challenge: Identifiable, Hashable {
    var id: UUID
    var initiator: User
    var receiver: User
    var habit: Habit?
    var type: ChallengeType
    var status: ChallengeStatus
    var startDate: Date
    var endDate: Date
    var createdAt: Date

    init(id: UUID, initiator: User, receiver: User, habit: Habit, type: ChallengeType, status: ChallengeStatus, startDate: Date, endDate: Date, createdAt: Date) {
        self.id = id
        self.initiator = initiator
        self.receiver = receiver
        self.habit = habit
        self.type = type
        self.status = status
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
    }
}

//
//  ChallengeDTO+swiftData.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.06.25.
//

import Foundation
extension ChallengeDTO {
    func toSwiftData(initiator: User, receiver: User, habit: Habit) -> Challenge {
        Challenge(
            id: self.id,
            initiator: initiator,
            receiver: receiver,
            habit: habit,
            status: self.status,
            startDate: self.startDate,
            endDate: self.endDate,
            createdAt: .now)
    }
}

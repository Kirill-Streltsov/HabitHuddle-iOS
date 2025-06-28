//
//  ChallengeDTO.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 06.06.25.
//

import Foundation

struct ChallengeDTO: Identifiable, Codable, Equatable {
    let id: UUID
    let initiatorHabitID: UUID?
    let receiverHabitID: UUID?
    let habitName: String
    let type: ChallengeType
    let startDate: Date
    let endDate: Date
    let status: ChallengeStatus
    let initiator: UserProgressDTO
    let receiver: UserProgressDTO

    struct UserProgressDTO: Codable {
        let user: UserDTO
        let progress: Double       // 0.0 to 1.0
        let checkInCount: Int
        let plannedDays: Int
    }
    
    static func == (lhs: ChallengeDTO, rhs: ChallengeDTO) -> Bool {
        let initiatorProgressesAreEqual = lhs.initiator.progress == rhs.initiator.progress
        let receiverProgressesAreEqual = lhs.receiver.progress == rhs.receiver.progress
        let idsAreEqual = lhs.id == rhs.id
        return initiatorProgressesAreEqual && receiverProgressesAreEqual && idsAreEqual
    }
}

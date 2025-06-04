//
//  ChallengeDTO.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import Foundation

struct ChallengeDTO: Identifiable, Codable {
    var id: UUID
    var initiator: LightweightUser
    var receiver: LightweightUser
    var habit: HabitDTO
    var type: ChallengeType
    var status: ChallengeStatus
    var startDate: Date
    var endDate: Date
    var createdAt: Date
}

//
//  ChallengeDTO.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import Foundation

struct ChallengeDTO: Identifiable {
    var id: UUID
    var initiatorName: String
    var receiverName: String
    var habitName: String
    var type: ChallengeType
    var status: ChallengeStatus
    var startDate: Date
    var endDate: Date
}

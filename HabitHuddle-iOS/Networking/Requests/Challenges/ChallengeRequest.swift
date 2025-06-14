//
//  ChallengeRequest.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import Foundation
struct ChallengeRequest: Codable {
    let receiverID: UUID
    let initiatorHabitID: UUID?
    let receiverHabitID: UUID?
    let startDate: Date
    let endDate: Date
    let type: ChallengeType
}

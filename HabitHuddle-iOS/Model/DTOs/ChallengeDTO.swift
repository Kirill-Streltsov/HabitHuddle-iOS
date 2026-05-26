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
        let statusesAreEqual = lhs.status == rhs.status
        let idsAreEqual = lhs.id == rhs.id
        return initiatorProgressesAreEqual && receiverProgressesAreEqual && statusesAreEqual && idsAreEqual
    }
}

enum ChallengeOutcome {
    case youWon      // I reached 100%, opponent did not
    case youLost     // opponent reached 100%, I did not
    case youAhead    // neither reached 100%, but I'm ahead
    case youBehind   // neither reached 100%, opponent is ahead
    case tied        // either both reached 100% or equal progress + equal check-ins
}

extension ChallengeDTO {
    /// Total length of the challenge in days, derived from start/end dates.
    var durationDays: Int {
        let calendar = Calendar(identifier: .gregorian)
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return max(days, 0) + 1
    }

    /// Determines the result of a past challenge from the perspective of `currentUserID`.
    /// Win/loss is reserved for someone reaching 100% — partial finishes use ahead/behind.
    func outcome(for currentUserID: UUID) -> ChallengeOutcome {
        let isInitiator = initiator.user.id == currentUserID
        let me = isInitiator ? initiator : receiver
        let them = isInitiator ? receiver : initiator

        let myProgress = min(me.progress, 1.0)
        let theirProgress = min(them.progress, 1.0)
        let iCompleted = myProgress >= 1.0
        let theyCompleted = theirProgress >= 1.0

        switch (iCompleted, theyCompleted) {
        case (true, true): return .tied
        case (true, false): return .youWon
        case (false, true): return .youLost
        case (false, false):
            if myProgress > theirProgress { return .youAhead }
            if myProgress < theirProgress { return .youBehind }
            if me.checkInCount > them.checkInCount { return .youAhead }
            if me.checkInCount < them.checkInCount { return .youBehind }
            return .tied
        }
    }
}

extension ChallengeDTO.UserProgressDTO {
    /// Server-clamped progress; falls back to a defensive client-side cap.
    var clampedProgress: Double { min(max(progress, 0), 1) }
}

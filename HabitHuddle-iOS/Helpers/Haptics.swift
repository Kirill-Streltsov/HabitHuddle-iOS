//
//  Haptics.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 30.05.25.
//

import UIKit

enum HapticType {
    case success
    case warning
    case error
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case selection
}

@MainActor
struct HapticManager {
    static func trigger(_ type: HapticType) {
        switch type {
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case let .impact(style):
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

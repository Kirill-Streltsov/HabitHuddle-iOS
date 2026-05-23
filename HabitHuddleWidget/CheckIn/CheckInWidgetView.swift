//
//  CheckInWidgetView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import WidgetKit
import SwiftUI

struct CheckInWidgetView: View {
    let entry: HabitEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let habit = entry.habit {
            switch family {
            case .systemMedium: CheckInMediumView(habit: habit)
            default:            CheckInSmallView(habit: habit)
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(.tertiaryLabel))
                Text(.longPressToSelectAHabit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Preview

#Preview("Has habit", as: .systemSmall) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: .placeholder)
}

#Preview("No habit selected", as: .systemSmall) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: nil)
}

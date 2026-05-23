//
//  CheckInSmallView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import SwiftUI
import AppIntents
import WidgetKit

struct CheckInSmallView: View {
    let habit: WidgetHabit

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            checkmarkView

            Spacer()

            Text(.days(habit.currentStreak))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    @ViewBuilder
    private var checkmarkView: some View {
        if habit.isCheckedInToday {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity)
                .symbolEffect(.bounce, options: .nonRepeating)
                .transition(.scale(scale: 0.4).combined(with: .opacity))
        } else {
            Button(intent: CheckInHabitIntent(habitID: habit.id)) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 64))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .transition(.scale(scale: 0.4).combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#Preview("Pending", as: .systemSmall) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: .placeholder)
}

#Preview("Checked in", as: .systemSmall) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: WidgetHabit.placeholders[0])
}

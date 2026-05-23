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
            HStack(spacing: 6) {
                if let icon = habit.icon {
                    Image(systemName: icon)
                        .font(.callout)
                        .frame(width: 28, height: 28)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }

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
                .font(.system(size: 52))
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity)
        } else {
            Button(intent: CheckInHabitIntent(habitID: habit.id)) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 52))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview("Pending") {
    CheckInSmallView(habit: .placeholder)
        .containerBackground(Color(.systemBackground), for: .widget)
        .frame(width: 165, height: 165)
}

#Preview("Checked in") {
    CheckInSmallView(habit: WidgetHabit.placeholders[0])
        .containerBackground(Color(.systemBackground), for: .widget)
        .frame(width: 165, height: 165)
}

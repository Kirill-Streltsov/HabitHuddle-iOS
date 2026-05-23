//
//  CheckInMediumView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import SwiftUI
import AppIntents
import WidgetKit

struct CheckInMediumView: View {
    let habit: WidgetHabit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if let icon = habit.icon {
                    Image(systemName: icon)
                        .font(.callout)
                        .frame(width: 30, height: 30)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Spacer()
                Text(.days(habit.currentStreak))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 0) {
                ForEach(0 ..< 7, id: \.self) { i in
                    VStack(spacing: 3) {
                        Circle()
                            .fill(habit.last7Days[i] ? Color.green : Color(.tertiarySystemBackground))
                            .frame(width: 9, height: 9)
                            .overlay(
                                Circle().stroke(Color.green.opacity(0.35), lineWidth: habit.last7Days[i] ? 0 : 1)
                            )
                        Text(weekdayLabel(index: i))
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Spacer(minLength: 0)

            checkmarkView
        }
        .padding()
    }

    @ViewBuilder
    private var checkmarkView: some View {
        if habit.isCheckedInToday {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity)
                .symbolEffect(.bounce, options: .nonRepeating)
                .transition(.scale(scale: 0.4).combined(with: .opacity))
        } else {
            Button(intent: CheckInHabitIntent(habitID: habit.id)) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 56))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .transition(.scale(scale: 0.4).combined(with: .opacity))
        }
    }

    private func weekdayLabel(index: Int) -> String {
        // index 0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun
        ["M", "T", "W", "T", "F", "S", "S"][index]
    }
}

// MARK: - Preview

#Preview("Pending", as: .systemMedium) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: .placeholder)
}

#Preview("Checked in", as: .systemMedium) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: WidgetHabit.placeholders[0])
}

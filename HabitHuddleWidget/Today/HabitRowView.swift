//
//  HabitRowView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import AppIntents
import SwiftUI
import WidgetKit

struct HabitRowView: View {
    let habit: WidgetHabit

    var body: some View {
        HStack(spacing: 10) {
            if habit.isCheckedInToday {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.body)
                    .frame(width: 18)
            } else {
                Button(intent: CheckInHabitIntent(habitID: habit.id)) {
                    Image(systemName: "circle")
                        .foregroundStyle(Color(.tertiaryLabel))
                        .font(.body)
                        .frame(width: 18)
                }
                .buttonStyle(.plain)
            }

            if let icon = habit.icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 14)
            }

            Text(habit.name)
                .font(.subheadline)
                .fontWeight(habit.isCheckedInToday ? .regular : .medium)
                .foregroundStyle(habit.isCheckedInToday ? .secondary : .primary)
                .strikethrough(habit.isCheckedInToday, color: Color(.tertiaryLabel))
                .lineLimit(1)

            Spacer()

            if habit.currentStreak > 0 {
                Text(.days(habit.currentStreak))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview("Pending", as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, habits: WidgetHabit.placeholders)
}

#Preview("Checked in", as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, habits: WidgetHabit.placeholders.map { var h = $0; h.isCheckedInToday = true; return h })
}

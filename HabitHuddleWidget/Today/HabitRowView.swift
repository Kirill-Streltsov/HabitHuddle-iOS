//
//  HabitRowView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import SwiftUI

// MARK: - Preview

#Preview("Pending") {
    HabitRowView(habit: .placeholder)
        .padding()
        .frame(width: 360)
}

#Preview("Checked in") {
    HabitRowView(habit: WidgetHabit.placeholders[0])
        .padding()
        .frame(width: 360)
}

struct HabitRowView: View {
    let habit: WidgetHabit

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: habit.isCheckedInToday ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(habit.isCheckedInToday ? .green : Color(.tertiaryLabel))
                .font(.body)
                .frame(width: 18)

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

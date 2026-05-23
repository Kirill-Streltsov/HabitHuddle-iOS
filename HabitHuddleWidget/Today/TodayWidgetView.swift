//
//  TodayWidgetView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import SwiftUI
import WidgetKit

// MARK: - Preview

#Preview("Medium – partial", as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, habits: WidgetHabit.placeholders)
}

#Preview("Medium – all done", as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, habits: WidgetHabit.placeholders.map {
        var h = $0; h.isCheckedInToday = true; return h
    })
}

#Preview("Medium – empty", as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, habits: [])
}

struct TodayWidgetView: View {
    let entry: TodayEntry
    @Environment(\.widgetFamily) var family

    private var maxRows: Int { family == .systemLarge ? 6 : 3 }
    private var doneCount: Int { entry.habits.filter { $0.isCheckedInToday }.count }
    private var total: Int { entry.habits.count }
    private var progress: Double { total == 0 ? 0 : Double(doneCount) / Double(total) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerView

            Divider()
                .padding(.vertical, 2)

            if entry.habits.isEmpty {
                Spacer()
                Text(.noHabitsYet)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ForEach(entry.habits.prefix(maxRows)) { habit in
                    HabitRowView(habit: habit)
                }
                if total > maxRows {
                    Text(.more(total - maxRows))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
    }

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(.today)
                    .font(.headline)
                if doneCount == total && total > 0 {
                    Text(.allDone)
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text(.ofDone(doneCount, total))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            CircularProgressView(progress: progress)
                .frame(width: 38, height: 38)
        }
    }
}

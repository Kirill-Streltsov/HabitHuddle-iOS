//
//  CircularProgressView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import SwiftUI
import WidgetKit

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemBackground), lineWidth: 3.5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progress == 1 ? Color.green : Color.accentColor,
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
            Text("\(Int(progress * 100))%")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(progress == 1 ? .green : .primary)
        }
    }
}

// MARK: - Preview

#Preview("0%", as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, habits: WidgetHabit.placeholders.map { var h = $0; h.isCheckedInToday = false; return h })
}

#Preview("Partial", as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, habits: WidgetHabit.placeholders)
}

#Preview("100%", as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, habits: WidgetHabit.placeholders.map { var h = $0; h.isCheckedInToday = true; return h })
}

//
//  TodayWidget.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import WidgetKit
import SwiftUI

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

#Preview("Large – partial", as: .systemLarge) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, habits: WidgetHabit.placeholders)
}

struct TodayWidget: Widget {
    let kind = "TodayWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHabitsIntent.self, provider: TodayWidgetProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(Color(.systemBackground), for: .widget)
        }
        .configurationDisplayName(Text(.todaysHabits))
        .description(Text(.seeAllYourHabitsForTodayAtAGlance))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

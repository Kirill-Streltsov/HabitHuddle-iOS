//
//  CheckInWidget.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import WidgetKit
import SwiftUI

struct CheckInWidget: Widget {
    let kind = "CheckInWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: CheckInWidgetProvider()) { entry in
            CheckInWidgetView(entry: entry)
                .containerBackground(Color(.systemBackground), for: .widget)
        }
        .configurationDisplayName(Text(.habitCheckIn))
        .description(Text(.checkInToAHabitFromYourHomeScreen))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview("Small – pending", as: .systemSmall) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: .placeholder)
}

#Preview("Small – done", as: .systemSmall) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: WidgetHabit.placeholders[0])
}

#Preview("Small – no habit", as: .systemSmall) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: nil)
}

#Preview("Medium – pending", as: .systemMedium) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: .placeholder)
}

#Preview("Medium – done", as: .systemMedium) {
    CheckInWidget()
} timeline: {
    HabitEntry(date: .now, habit: WidgetHabit.placeholders[0])
}

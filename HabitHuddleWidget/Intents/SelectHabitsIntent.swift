//
//  SelectHabitsIntent.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 24.05.26.
//

import AppIntents
import WidgetKit

struct SelectHabitsIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Select Habits"
    static let description = IntentDescription("Choose which habits to display.")

    @Parameter(title: "Habits")
    var habits: [HabitEntity]?
}

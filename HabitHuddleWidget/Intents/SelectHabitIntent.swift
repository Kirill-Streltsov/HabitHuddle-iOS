//
//  SelectHabitIntent.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import AppIntents
import WidgetKit

struct SelectHabitIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Select Habit"
    static let description = IntentDescription("Choose which habit to display.")

    @Parameter(title: "Habit")
    var habit: HabitEntity?
}

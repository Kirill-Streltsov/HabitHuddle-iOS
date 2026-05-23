//
//  TodayEntry.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import WidgetKit

struct TodayEntry: TimelineEntry {
    let date: Date
    let habits: [WidgetHabit]
}

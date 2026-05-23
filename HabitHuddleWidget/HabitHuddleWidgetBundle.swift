//
//  HabitHuddleWidgetBundle.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import WidgetKit
import SwiftUI

@main
struct HabitHuddleWidgetBundle: WidgetBundle {
    var body: some Widget {
        CheckInWidget()
        TodayWidget()
    }
}

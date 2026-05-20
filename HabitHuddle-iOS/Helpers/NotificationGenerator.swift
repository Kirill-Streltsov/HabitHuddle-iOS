//
//  NotificationGenerator.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 06.07.25.
//

import Foundation

struct HabitNotification {
    let title: String
    let subtitle: String
    let body: String
}

struct NotificationGenerator {
    static func randomNotification(for habitName: String) -> HabitNotification {
        let templates: [HabitNotification] = [
            HabitNotification(
                title: String(localized: .stayOnTrack),
                subtitle: String(localized: .yourHabitNeedsYouToday),
                body: String(localized: .dontForgetToCheckInForSmallStepsLeadToBigChanges(habitName))
            ),
            HabitNotification(
                title: String(localized: .🌅NewDayNewWin),
                subtitle: String(localized: .timeToBuildMomentum),
                body: String(localized: .startYourDayStrongWithYouveGotThis(habitName))
            ),
            HabitNotification(
                title: String(localized: .📈TinyHabitsBigResults),
                subtitle: String(localized: .yourFutureSelfIsWatching),
                body: String(localized: .youreJustOneCheckInAwayFromProgressLetsCrushToday(habitName))
            ),
            HabitNotification(
                title: String(localized: .itsHabitOclock),
                subtitle: String(localized: .stayConsistentStayStrong),
                body: String(localized: .nowsThePerfectTimeToCompleteKeepTheStreakAlive(habitName))
            )
        ]

        return templates.randomElement() ?? templates[0]
    }
}

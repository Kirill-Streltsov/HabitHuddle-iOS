//
//  OnboardingPageData.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct OnboardingPageData: Identifiable {
    let id = UUID()
    var symbol: String
    var title: String
    var text: String
    var customView: AnyView
    var requestsNotificationPermission: Bool = false
}

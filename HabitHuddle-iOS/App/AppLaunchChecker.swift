//
//  AppLaunchChecker.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.05.25.
//

import Foundation

enum AppLaunchChecker {
    private static let hasLaunchedKey = "hasLaunchedBefore"

    static func clearKeychainIfFreshInstall() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: hasLaunchedKey)

        if !hasLaunchedBefore {
            // Fresh install detected
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
            TokenManager.clearAll()
            print("Fresh install detected. Keychain cleared.")
        }
    }
}

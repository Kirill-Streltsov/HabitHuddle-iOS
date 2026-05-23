//
//  SharedModelContainer.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import SwiftData
import Foundation

enum SharedModelContainer {
    static let appGroupID = "group.com.krlsrlsv.HabitHuddle-iOS"

    static var storeURL: URL {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
            .appendingPathComponent("HabitHuddle.store")
    }

    static func make() -> ModelContainer? {
        let schema = Schema([User.self, Habit.self, Challenge.self, HabitCheckIn.self])
        let config = ModelConfiguration(schema: schema, url: storeURL)
        return try? ModelContainer(for: schema, configurations: [config])
    }
}

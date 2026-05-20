//
//  ModelContainerHelper.swift
//  HabitHuddle-iOSTests
//

import SwiftData
import Foundation
@testable import HabitHuddle_iOS

enum ModelContainerHelper {
    static func makeInMemory() throws -> ModelContainer {
        let schema = Schema([Habit.self, HabitCheckIn.self, Challenge.self, User.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: config)
    }
}

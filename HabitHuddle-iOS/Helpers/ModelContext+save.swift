//
//  ModelContext+save.swift
//  HabitHuddle-iOS
//

import SwiftData

extension ModelContext {
    func saveOrLog() {
        do {
            try save()
        } catch {
            print("❌ Failed to save context: \(error)")
        }
    }
}

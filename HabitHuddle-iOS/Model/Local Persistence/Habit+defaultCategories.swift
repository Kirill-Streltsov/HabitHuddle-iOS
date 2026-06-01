//
//  Habit+defaultCategories.swift
//  HabitHuddle-iOS
//

import Foundation

extension Habit {
    /// The built-in category suggestions. These always appear in the habit editor's category picker
    /// and in Settings → Manage Categories, even when no habit uses them yet. Categories aren't a
    /// stored entity — they only exist as the `category` string on habits — so these are the seed set.
    static var defaultCategorySuggestions: [String] {
        [
            String(localized: .health),
            String(localized: .productivity),
            String(localized: .mindfulness),
            String(localized: .learning),
            String(localized: .fitness)
        ]
    }
}

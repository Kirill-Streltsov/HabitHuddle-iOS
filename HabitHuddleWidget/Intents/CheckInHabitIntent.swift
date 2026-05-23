//
//  CheckInHabitIntent.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import AppIntents
import WidgetKit

struct CheckInHabitIntent: AppIntent {
    static let title: LocalizedStringResource = "Check In"
    static let description = IntentDescription("Mark a habit as done for today.")
    static let isDiscoverable = false

    @Parameter(title: "Habit ID")
    var habitID: String

    init() {}
    init(habitID: UUID) { self.habitID = habitID.uuidString }

    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: habitID) else { return .result() }

        WidgetDataStore.markCheckedIn(habitID: id)

        if let token = WidgetDataStore.loadToken() {
            let base = WidgetDataStore.loadBaseURL()
            if let url = URL(string: "\(base)habits/\(id.uuidString)/toggle-checkin") {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                _ = try? await URLSession.shared.data(for: request)
            }
        }

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

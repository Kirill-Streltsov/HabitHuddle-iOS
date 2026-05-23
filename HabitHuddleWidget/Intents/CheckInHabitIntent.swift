//
//  CheckInHabitIntent.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import AppIntents
import SwiftData
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

        insertCheckIn(habitID: id)
        WidgetDataStore.markCheckedIn(habitID: id)
        WidgetDataStore.addPendingCheckIn(habitID: id)

        if let token = WidgetDataStore.loadToken() {
            let base = WidgetDataStore.loadBaseURL()
            if let url = URL(string: "\(base)habits/\(id.uuidString)/toggle-checkin") {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                if let (_, response) = try? await URLSession.shared.data(for: request),
                   (response as? HTTPURLResponse)?.statusCode == 200 {
                    WidgetDataStore.removePendingCheckIn(habitID: id)
                }
            }
        }

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    private func insertCheckIn(habitID: UUID) {
        guard let container = SharedModelContainer.make() else { return }
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == habitID })
        guard let habit = try? context.fetch(descriptor).first else { return }
        let alreadyDone = habit.checkIns.contains { Calendar.current.isDate($0.date, inSameDayAs: .now) }
        guard !alreadyDone else { return }
        let checkIn = HabitCheckIn(date: .now, habit: habit, habitID: habitID)
        context.insert(checkIn)
        try? context.save()
    }
}

//
//  NewHabitViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftUI
import SwiftData

extension NewHabitView {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var name: String = "This is a new habit"
        @Published var description: String = "This is a description"
        @Published var frequency: HabitFrequency = .daily
        @Published var reminderTime: Date?
        @Published var createdAt: Date?
        @Published var updatedAt: Date?
        
        func sendHabit() async {
            do {
                let payload = HabitPayload(name: name, description: description, frequency: frequency.rawValue)
                let habitResponse = try await NetworkingManager.shared.request(
                    endpoint: .createHabit(),
                    method: .post,
                    body: payload,
                    responseType: CodableHabit.self)
                
                print("THIS IS A RESPONSE: \(habitResponse)")
            } catch {
                if let apiError = error as? APIError {
                    print(apiError.localizedDescription)
                }
            }
        }
        
        
    }
}

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
        
        @State var name: String = ""
        @State var description: String = ""
        @State var frequency: HabitFrequency = .daily
        @State var reminderTime: Date?
        @State var createdAt: Date?
        @State var updatedAt: Date?
        
        
        func sendHabit() async {
            do {
                let payload = HabitPayload(name: name, description: description, frequency: frequency.rawValue)
                let habitResponse = try await NetworkingManager.shared.request(
                    endpoint: .createHabit(),
                    method: .post,
                    body: payload,
                    responseType: CodableHabit.self)
                
                print(habitResponse)
            } catch {
                if let apiError = error as? APIError {
                    print(apiError.localizedDescription)
                }
            }
        }
    }
}

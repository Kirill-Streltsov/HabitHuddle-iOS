//
//  NewHabitViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftData
import SwiftUI

extension NewHabitView {
    @MainActor
    final class ViewModel: ObservableObject {
        let appState: AppState

        @Published var name: String = "Drink water"
        @Published var description: String = "Gotta stay hydrated :)"
        @Published var frequency: HabitFrequency = .daily

        init(appState: AppState) {
            self.appState = appState
        }

        func sendHabit() async -> Result<CodableHabit, APIError> {
            do {
                let payload = HabitPayload(name: name, description: description, frequency: frequency.rawValue)
                let habitResponse = try await NetworkingManager.shared.request(
                    endpoint: .createHabit(),
                    method: .post,
                    body: payload,
                    responseType: CodableHabit.self
                )
                return .success(habitResponse)
            } catch let error as APIError {
                return .failure(error)
            } catch {
                return .failure(.unknown)
            }
        }
    }
}

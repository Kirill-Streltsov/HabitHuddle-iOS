//
//  RegistrationViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Observation
import SwiftUI

extension RegistrationView {
    @MainActor
    @Observable final class ViewModel {
        private let appState: AppState

        var username: String = ""
        var name: String = ""
        var password: String = ""
        var errorMessage: String = ""

        public init(appState: AppState) {
            self.appState = appState
        }

        func registerUser(username: String, name: String, password: String) async {
            let payload = RegisterRequest(username: username, name: name, password: password)

            do {
                let registrationResponse = try await NetworkingManager.shared.request(
                    endpoint: .register(),
                    method: .post,
                    body: payload,
                    responseType: LoginResponse.self
                )
                withAnimation {
                    appState.isAuthenticated = true
                }
                print(registrationResponse)
            } catch {
                if let apiError = error as? APIError {
                    errorMessage = apiError.localizedDescription
                } else {
                    errorMessage = "Something went wrong. Please try again."
                }
            }
        }
    }
}

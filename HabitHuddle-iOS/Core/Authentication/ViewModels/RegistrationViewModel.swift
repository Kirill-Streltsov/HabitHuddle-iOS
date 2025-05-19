//
//  RegistrationViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation
import Observation

extension RegistrationView {
    @MainActor
    @Observable class ViewModel {
        var username: String = ""
        var name: String = ""
        var password: String = ""
        var errorMessage: String = ""

        func registerUser(username: String, name: String, password: String) async {
            let payload = RegisterUserRequest(username: username, name: name, password: password)

            do {
                let registrationData = try await NetworkingManager.shared.request(
                    endpoint: .register(),
                    method: .post,
                    body: payload,
                    responseType: RegisterUserResponse.self
                )
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

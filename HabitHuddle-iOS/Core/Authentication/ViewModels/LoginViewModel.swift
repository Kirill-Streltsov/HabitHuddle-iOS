//
//  LoginViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Observation
import SwiftUI

extension LoginView {
    @MainActor
    @Observable final class ViewModel {
        private let appState: AppState

        var username: String = ""
        var password: String = ""
        var errorMessage: String = ""

        public init(appState: AppState) {
            self.appState = appState
        }

        func loginUser(username: String, password: String) async {
            let username = username
            let password = password
            let loginString = "\(username):\(password)"
            guard let loginData = loginString.data(using: .utf8) else {
                print("Could not encode login string: \(loginString)")
                return
            }

            let base64LoginString = loginData.base64EncodedString()

            do {
                let headers = [
                    "Authorization": "Basic \(base64LoginString)",
                ]
                let loginResponse = try await NetworkingManager.shared.request(
                    endpoint: .login(),
                    method: .post,
                    headers: headers,
                    responseType: LoginResponse.self
                )
                withAnimation {
                    appState.isAuthenticated = true
                }
                print(loginResponse)
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

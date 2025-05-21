//
//  LoginViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Observation
import SwiftData
import SwiftUI

extension LoginView {
    @MainActor
    final class ViewModel: ObservableObject {
        let appState: AppState
        let modelContext: ModelContext

        @Published var username: String = ""
        @Published var password: String = ""
        @Published var errorMessage: String = ""

        init(appState: AppState, modelContext: ModelContext) {
            self.appState = appState
            self.modelContext = modelContext
        }

        func loginUser(username: String, password: String) async {
            guard let base64Login = makeBase64Login(username: username, password: password) else {
                errorMessage = "Invalid credentials format."
                return
            }

            do {
                let headers = ["Authorization": "Basic \(base64Login)"]
                let loginResponse = try await NetworkingManager.shared.request(
                    endpoint: .login(),
                    method: .post,
                    headers: headers,
                    responseType: LoginResponse.self
                )

                TokenManager.token = loginResponse.token
                saveUserIfNeeded(loginResponse.user)

                withAnimation {
                    appState.isAuthenticated = true
                }
            } catch {
                if let apiError = error as? APIError {
                    errorMessage = apiError.localizedDescription
                } else {
                    errorMessage = "Something went wrong. Please try again."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.errorMessage = ""
                }
            }
        }

        private func makeBase64Login(username: String, password: String) -> String? {
            let loginString = "\(username):\(password)"
            return loginString.data(using: .utf8)?.base64EncodedString()
        }

        private func saveUserIfNeeded(_ user: DecodableUser) {
            let userID = user.id
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate { $0.id == userID }
            )

            guard (try? modelContext.fetch(descriptor).first) == nil else {
                return
            }

            let newUser = User(
                id: user.id,
                username: user.username,
                name: user.name,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt
            )

            modelContext.insert(newUser)
        }
    }
}

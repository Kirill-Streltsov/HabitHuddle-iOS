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
    @Observable final class ViewModel {
        private let appState: AppState
        private let modelContext: ModelContext
        
        var username: String = ""
        var password: String = ""
        var errorMessage: String = ""
        
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
            } catch let apiError as APIError {
                errorMessage = apiError.localizedDescription
            } catch {
                errorMessage = "Something went wrong. Please try again."
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

//
//  RegistrationViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Observation
import SwiftData
import SwiftUI

extension RegistrationView {
    @MainActor
    final class ViewModel: ObservableObject {
        let appState: AppState
        let userManager: LocalUserManager

        @Published var errorMessage: String = ""

        public init(appState: AppState, userManager: LocalUserManager) {
            self.appState = appState
            self.userManager = userManager
        }

        func registerUser(username: String, name: String, password: String, context: ModelContext) async throws -> Result<UserDTO, APIError> {
            let payload = RegisterPayload(id: userManager.profile.id, username: username, name: name, password: password)

            do {
                let registrationResponse = try await NetworkingManager.shared.request(
                    endpoint: .register(),
                    method: .post,
                    body: payload,
                    responseType: LoginResponse.self
                )
                
                let user = registrationResponse.user
                let userToSave = User(
                    id: user.id,
                    username: user.username,
                    name: user.name,
                    createdAt: user.createdAt,
                    updatedAt: user.updatedAt
                )
                userManager.profile = LocalUser(
                    id: userToSave.id,
                    username: userToSave.username,
                    name: userToSave.name,
                    isSignedInToServer: true)
                context.insert(userToSave)
                TokenManager.token = registrationResponse.token
                appState.isAuthenticated = true
                return .success(user)
            } catch {
                if let apiError = error as? APIError {
                    errorMessage = apiError.localizedDescription
                } else {
                    errorMessage = "Something went wrong. Please try again."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.errorMessage = ""
                }
                return .failure(APIError.networkError(error))
            }
        }
    }
}

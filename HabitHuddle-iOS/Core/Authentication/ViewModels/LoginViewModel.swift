//
//  LoginViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import SwiftData
import SwiftUI

extension LoginView {
    @MainActor
    final class ViewModel: ObservableObject {
        let appState: AppState
        let userManager: LocalUserManager

        @Published var errorMessage: String = ""

        init(appState: AppState, userManager: LocalUserManager) {
            self.appState = appState
            self.userManager = userManager
        }

        func loginUser(username: String, password: String) async -> UserDTO? {
            let base64Login = makeBase64Login(username: username, password: password)

            do {
                let headers = ["Authorization": "Basic \(base64Login)"]
                let loginResponse = try await NetworkManager.shared.request(
                    endpoint: .login(),
                    method: .post,
                    headers: headers,
                    responseType: LoginResponse.self,
                    isLoggingIn: true
                )

                TokenManager.token = loginResponse.token
                let user = loginResponse.user
                userManager.profile = LocalUser(
                    id: user.id,
                    username: user.username,
                    name: user.name,
                    isSignedInToServer: true)
                return loginResponse.user

            } catch {
                if let apiError = error as? APIError {
                    errorMessage = apiError.localizedDescription
                } else {
                    errorMessage = "Something went wrong. Please try again."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.errorMessage = ""
                }
                return nil
            }
        }

        private func makeBase64Login(username: String, password: String) -> String {
            let loginString = "\(username):\(password)"
            if let data = loginString.data(using: .utf8) {
                return data.base64EncodedString()
            } else {
                fatalError("Couldn't encode your username or password")
            }
        }

        func saveUser(_ user: UserDTO, using context: ModelContext) {
            let descriptor = FetchDescriptor<User>()

            do {
                let existingUsers = try context.fetch(descriptor)

                // Delete all previous instances
                for user in existingUsers {
                    context.delete(user)
                }

                let newUser = User(
                    id: user.id,
                    username: user.username,
                    name: user.name,
                    createdAt: user.createdAt,
                    updatedAt: user.updatedAt
                )
                context.insert(newUser)
                appState.isAuthenticated = true
            } catch {
                fatalError("Couldn't save user's information")
            }
        }

        func getUserHabits() async -> Result<[HabitDTO], APIError> {
            do {
                let habits = try await NetworkManager.shared.request(
                    endpoint: .getMyHabits(),
                    method: .get,
                    responseType: [HabitDTO].self
                )
                return .success(habits)
            } catch let error as APIError {
                return .failure(error)
            } catch {
                return .failure(.unknown)
            }
        }
    }
}

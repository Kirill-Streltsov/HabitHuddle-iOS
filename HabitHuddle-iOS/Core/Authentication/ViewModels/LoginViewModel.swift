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
                if let apiError = error as? HHError {
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
        
        func handleGoogleSignIn() async -> UserDTO? {
            // Wrap the callback-based Google sign-in into async/await
            let idToken = await withCheckedContinuation { [weak self] continuation in
                GoogleAuthManager.shared.signIn { result in
                    switch result {
                    case .success(let idToken):
                        continuation.resume(returning: idToken)
                    case .failure(let error):
                        guard let strongSelf = self else { return }
                        if let apiError = error as? HHError {
                            strongSelf.errorMessage = apiError.localizedDescription
                        } else {
                            strongSelf.errorMessage = "Something went wrong. Please try again."
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            strongSelf.errorMessage = ""
                        }
                    }
                }
            }
            
            do {
                let loginResponse = try await NetworkManager.shared.request(
                    endpoint: .googleSignIn(),
                    method: .post,
                    body: GoogleTokenRequest(idToken: idToken),
                    responseType: LoginResponse.self,
                    isLoggingIn: true
                )
                
                TokenManager.token = loginResponse.token
                let user = loginResponse.user
                userManager.profile = LocalUser(
                    id: user.id,
                    username: user.username,
                    name: user.name,
                    isSignedInToServer: true
                )
                                
                return loginResponse.user
            } catch {
                if let apiError = error as? HHError {
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

        func getUserHabits() async -> Result<[HabitDTO], HHError> {
            do {
                let habits = try await NetworkManager.shared.request(
                    endpoint: .getMyHabits(),
                    method: .get,
                    responseType: [HabitDTO].self
                )
                return .success(habits)
            } catch {
                return .failure(.networkError(error))
            }
        }
    }
}

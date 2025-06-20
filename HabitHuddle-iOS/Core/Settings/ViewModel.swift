//
//  ViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.06.25.
//

import Foundation

extension SettingsView {
    @MainActor
    final class ViewModel: ObservableObject {
        
        func handleGoogleSignIn() async -> UserDTO? {
            // Wrap the callback-based Google sign-in into async/await
            let idToken = await withCheckedContinuation { continuation in
                GoogleAuthManager.shared.signIn { result in
                    switch result {
                    case .success(let idToken):
                        continuation.resume(returning: idToken)
                    case .failure(let error):
                        print("❌ Error: Failed to sign in with google")
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
                return loginResponse.user
            } catch {
                print("❌ Error: Failed to sign in with google")
                return nil
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

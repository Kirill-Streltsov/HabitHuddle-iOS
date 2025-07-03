//
//  RegistrationViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import SwiftData
import SwiftUI

extension RegistrationView {
    @MainActor
    final class ViewModel: ObservableObject {

        @Published var errorMessage: String = ""
        @Published var loadedUser = UserDTO(id: UUID(), username: "", name: "", createdAt: nil, updatedAt: nil)

        func registerUser(userID: UUID, username: String, name: String, password: String) async throws  {
            let payload = RegisterPayload(id: userID, username: username, name: name, password: password)

            do {
                let registrationResponse = try await NetworkManager.shared.request(
                    endpoint: .register(),
                    method: .post,
                    body: payload,
                    responseType: LoginResponse.self,
                    isLoggingIn: true
                )
                
                loadedUser = registrationResponse.user
                TokenManager.token = registrationResponse.token
                
            } catch {
                if let apiError = error as? HHError {
                    errorMessage = apiError.localizedDescription
                } else {
                    errorMessage = "Something went wrong. Please try again."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.errorMessage = ""
                }
            }
        }
    }
}

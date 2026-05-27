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

        @AppStorage("deviceToken") private var deviceToken: String = ""

        @Published var errorMessage: String = ""
        @Published var registeredUser: UserDTO? = nil
        @Published var isSubmitting: Bool = false

        private let network: any NetworkManagerProtocol

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
        }

        func registerUser(userID: UUID, username: String, name: String, email: String, password: String) async throws {
            // Normalize so the account is stored under the same casing the password-reset
            // and verification lookups use; otherwise those lookups silently miss.
            let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let payload = UserPayload(
                id: userID,
                username: username,
                name: name,
                email: normalizedEmail,
                password: password,
                deviceToken: deviceToken
            )

            isSubmitting = true
            defer { isSubmitting = false }

            do {
                let response = try await network.request(
                    endpoint: .register(),
                    method: .post,
                    body: payload,
                    responseType: LoginResponse.self,
                    isLoggingIn: true
                )

                TokenManager.token = response.token
                registeredUser = response.user

            } catch {
                if let apiError = error as? HHError {
                    errorMessage = apiError == .conflict
                        ? String(localized: .emailIsAlreadyInUse)
                        : apiError.localizedDescription
                } else {
                    errorMessage = String(localized: .somethingWentWrongPleaseTryAgain)
                }
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    self.errorMessage = ""
                }
            }
        }
    }
}

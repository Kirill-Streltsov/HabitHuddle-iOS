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
            let payload = UserPayload(
                id: userID,
                username: username,
                name: name,
                email: email,
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
                    errorMessage = apiError.localizedDescription
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

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
        @Published var loadedUser = UserDTO(id: UUID(), username: "", name: "", createdAt: nil, updatedAt: nil)

        private let network: any NetworkManagerProtocol

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
        }

        func registerUser(userID: UUID, username: String, name: String, password: String) async throws {
            let payload = UserPayload(
                id: userID,
                username: username,
                name: name,
                password: password,
                deviceToken: deviceToken
            )

            do {
                let registrationResponse = try await network.request(
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
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    self.errorMessage = ""
                }
            }
        }
    }
}

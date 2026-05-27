//
//  ForgotPasswordViewModel.swift
//  HabitHuddle-iOS
//

import SwiftUI

extension ForgotPasswordView {
    @MainActor
    final class ViewModel: ObservableObject {

        @Published var errorMessage: String = ""
        @Published var didRequestReset: Bool = false
        @Published var isSubmitting: Bool = false

        private let network: any NetworkManagerProtocol

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
        }

        func requestReset(email: String) async {
            let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard trimmed.isValidEmail else {
                errorMessage = String(localized: .pleaseEnterAValidEmailAddress)
                scheduleErrorClear()
                return
            }

            isSubmitting = true
            defer { isSubmitting = false }

            do {
                _ = try await network.requestStatusCode(
                    endpoint: .forgotPassword(),
                    method: .post,
                    body: ForgotPasswordRequest(email: trimmed),
                    headers: nil,
                    isLoggingIn: true
                )
                didRequestReset = true
            } catch {
                if let apiError = error as? HHError {
                    errorMessage = apiError.localizedDescription
                } else {
                    errorMessage = String(localized: .somethingWentWrongPleaseTryAgain)
                }
                scheduleErrorClear()
            }
        }

        private func scheduleErrorClear() {
            Task {
                try? await Task.sleep(for: .seconds(3))
                self.errorMessage = ""
            }
        }
    }
}

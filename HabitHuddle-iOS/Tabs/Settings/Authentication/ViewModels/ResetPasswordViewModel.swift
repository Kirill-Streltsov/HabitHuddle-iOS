//
//  ResetPasswordViewModel.swift
//  HabitHuddle-iOS
//

import SwiftUI

extension ResetPasswordView {
    @MainActor
    final class ViewModel: ObservableObject {

        @Published var errorMessage: String = ""
        @Published var didResetPassword: Bool = false
        @Published var isSubmitting: Bool = false

        private let network: any NetworkManagerProtocol

        init(network: any NetworkManagerProtocol = NetworkManager.shared) {
            self.network = network
        }

        func resetPassword(token: String, newPassword: String) async {
            guard newPassword.count >= 5 else {
                errorMessage = String(localized: .yourPasswordShouldHaveAtLeast5Symbols)
                scheduleErrorClear()
                return
            }

            isSubmitting = true
            defer { isSubmitting = false }

            do {
                let status = try await network.requestStatusCode(
                    endpoint: .resetPassword(),
                    method: .post,
                    body: ResetPasswordRequest(token: token, newPassword: newPassword),
                    headers: nil,
                    isLoggingIn: true
                )
                switch status {
                case .ok:
                    didResetPassword = true
                case .gone:
                    errorMessage = String(localized: .thisResetLinkHasExpiredPleaseRequestANewOne)
                    scheduleErrorClear()
                default:
                    errorMessage = String(localized: .invalidOrExpiredResetLink)
                    scheduleErrorClear()
                }
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

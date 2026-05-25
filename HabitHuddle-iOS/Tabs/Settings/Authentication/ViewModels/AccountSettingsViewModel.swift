//
//  AccountSettingsViewModel.swift
//  HabitHuddle-iOS
//

import SwiftUI

@MainActor
final class AccountSettingsViewModel: ObservableObject {

    @Published var errorMessage: String = ""
    @Published var isSubmitting: Bool = false
    @Published var lastUpdatedUser: UserDTO?
    @Published var didSendEmailVerification: Bool = false

    private let network: any NetworkManagerProtocol

    init(network: any NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    // MARK: - Name

    func updateName(newName: String, currentName: String) async {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            setError(String(localized: .nameCannotBeEmpty))
            return
        }
        guard trimmed != currentName else { return }

        await submit(UpdateProfileRequest(
            name: trimmed,
            username: nil,
            email: nil,
            newPassword: nil,
            currentPassword: nil
        ))
    }

    // MARK: - Username

    func updateUsername(newUsername: String, currentUsername: String) async {
        let trimmed = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else {
            setError(String(localized: .usernameShouldHaveAtLeast3Symbols))
            return
        }
        guard trimmed != currentUsername else { return }

        await submit(UpdateProfileRequest(
            name: nil,
            username: trimmed,
            email: nil,
            newPassword: nil,
            currentPassword: nil
        ))
    }

    // MARK: - Email

    func updateEmail(newEmail: String, currentEmail: String?, currentPassword: String) async {
        let trimmed = newEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmed.contains("@"), trimmed.count >= 3 else {
            setError(String(localized: .pleaseEnterAValidEmailAddress))
            return
        }
        guard trimmed != (currentEmail ?? "").lowercased() else { return }
        guard !currentPassword.isEmpty else {
            setError(String(localized: .enterYourCurrentPasswordToAuthorizeThisChange))
            return
        }

        didSendEmailVerification = false
        await submit(UpdateProfileRequest(
            name: nil,
            username: nil,
            email: trimmed,
            newPassword: nil,
            currentPassword: currentPassword
        ), onSuccess: { [weak self] _ in
            self?.didSendEmailVerification = true
        })
    }

    // MARK: - Password

    func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) async {
        guard !currentPassword.isEmpty else {
            setError(String(localized: .enterYourCurrentPasswordToAuthorizeThisChange))
            return
        }
        guard newPassword.count >= 5 else {
            setError(String(localized: .yourPasswordShouldHaveAtLeast5Symbols))
            return
        }
        guard newPassword == confirmPassword else {
            setError(String(localized: .makeSureBothPasswordFieldsAreTheSame))
            return
        }
        guard newPassword != currentPassword else {
            setError(String(localized: .yourNewPasswordMustBeDifferentFromTheCurrentOne))
            return
        }

        await submit(UpdateProfileRequest(
            name: nil,
            username: nil,
            email: nil,
            newPassword: newPassword,
            currentPassword: currentPassword
        ))
    }

    // MARK: - Shared submit

    private func submit(_ request: UpdateProfileRequest, onSuccess: ((UserDTO) -> Void)? = nil) async {
        errorMessage = ""
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let updated = try await network.request(
                endpoint: .updateUser(),
                method: .put,
                body: request,
                headers: nil,
                responseType: UserDTO.self,
                isLoggingIn: false
            )
            lastUpdatedUser = updated
            onSuccess?(updated)
        } catch let apiError as HHError {
            setError(apiError.localizedDescription)
        } catch {
            setError(String(localized: .somethingWentWrongPleaseTryAgain))
        }
    }

    private func setError(_ message: String) {
        errorMessage = message
        scheduleErrorClear()
    }

    private func scheduleErrorClear() {
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(4))
            self?.errorMessage = ""
        }
    }
}

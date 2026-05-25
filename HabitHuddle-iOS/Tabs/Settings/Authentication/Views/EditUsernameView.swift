//
//  EditUsernameView.swift
//  HabitHuddle-iOS
//

import SwiftUI

struct EditUsernameView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var userManager: LocalUserManager

    @StateObject private var viewModel = AccountSettingsViewModel()

    @State private var username: String = ""
    @State private var didLoad = false

    @FocusState private var focused: Bool

    private var trimmed: String { username.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var disabled: Bool {
        trimmed.count < 3 || trimmed == userManager.profile.username || viewModel.isSubmitting
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                FormHeader(icon: "at", title: .editUsername, subtitle: nil)
                FormErrorBanner(message: viewModel.errorMessage)

                FormCard {
                    FormFieldRow(icon: "at", color: .blue) {
                        TextField(String(localized: .enterYourUsername), text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textContentType(.username)
                            .submitLabel(.done)
                            .focused($focused)
                            .onSubmit { submit() }
                    }
                }

                FormPrimaryButton(
                    title: .saveChanges,
                    isLoading: viewModel.isSubmitting,
                    disabled: disabled,
                    action: submit
                )
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(String(localized: .editUsername))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if !didLoad {
                username = userManager.profile.username
                didLoad = true
                focused = true
            }
        }
        .onChange(of: viewModel.lastUpdatedUser) { _, newValue in
            guard let newValue else { return }
            userManager.profile = LocalUser(
                id: newValue.id,
                username: newValue.username,
                name: newValue.name,
                email: newValue.email ?? userManager.profile.email,
                isSignedInToServer: true,
                isEmailVerified: newValue.isEmailVerified
            )
            HapticManager.trigger(.success)
            dismiss()
        }
    }

    private func submit() {
        focused = false
        Task {
            await viewModel.updateUsername(newUsername: username, currentUsername: userManager.profile.username)
        }
    }
}

#Preview {
    NavigationStack {
        EditUsernameView()
            .environmentObject(LocalUserManager())
    }
}

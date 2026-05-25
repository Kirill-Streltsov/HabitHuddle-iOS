//
//  ChangeEmailView.swift
//  HabitHuddle-iOS
//

import SwiftUI

struct ChangeEmailView: View {

    enum Field {
        case email, password
    }

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var userManager: LocalUserManager

    @StateObject private var viewModel = AccountSettingsViewModel()

    @State private var newEmail: String = ""
    @State private var currentPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showVerificationAlert: Bool = false

    @FocusState private var focused: Field?

    private var trimmedEmail: String {
        newEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var disabled: Bool {
        viewModel.isSubmitting
            || !trimmedEmail.contains("@")
            || trimmedEmail == (userManager.profile.email ?? "").lowercased()
            || currentPassword.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                FormHeader(
                    icon: "envelope.badge.fill",
                    title: .changeEmail,
                    subtitle: .wellSendAConfirmationLinkToVerifyTheChange
                )

                FormErrorBanner(message: viewModel.errorMessage)

                FormCard {
                    FormFieldRow(icon: "envelope.fill", color: .green) {
                        TextField(String(localized: .enterYourNewEmail), text: $newEmail)
                            .textInputAutocapitalization(.never)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .focused($focused, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focused = .password }
                    }
                }

                FormCard {
                    FormFieldRow(icon: "lock.fill", color: .purple) {
                        Group {
                            if showPassword {
                                TextField(String(localized: .enterYourCurrentPassword), text: $currentPassword)
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField(String(localized: .enterYourCurrentPassword), text: $currentPassword)
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                        }
                        .focused($focused, equals: .password)
                        .submitLabel(.done)
                        .onSubmit { submit() }

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                        }
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
        .navigationTitle(String(localized: .changeEmail))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            focused = .email
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
        }
        .onChange(of: viewModel.didSendEmailVerification) { _, sent in
            if sent {
                HapticManager.trigger(.success)
                showVerificationAlert = true
            }
        }
        .alert(Text(.emailSent), isPresented: $showVerificationAlert) {
            Button {
                dismiss()
            } label: {
                Text(.gotIt)
            }
        } message: {
            Text(.weSentAConfirmationLinkToYourNewEmailAddressTapItToFinishUpdatingYourAccount)
        }
    }

    private func submit() {
        focused = nil
        Task {
            await viewModel.updateEmail(
                newEmail: newEmail,
                currentEmail: userManager.profile.email,
                currentPassword: currentPassword
            )
        }
    }
}

#Preview {
    NavigationStack {
        ChangeEmailView()
            .environmentObject(LocalUserManager())
    }
}

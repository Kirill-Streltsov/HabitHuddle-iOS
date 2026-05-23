//
//  RegistrationView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftData
import SwiftUI

struct RegistrationView: View {
    enum Field {
        case username, name, email, password, confirmPassword
    }

    @Query var habits: [Habit]

    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var userManager: LocalUserManager
    @EnvironmentObject var appState: AppState

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var registerButtonPressed = false
    @State private var showEmailSentAlert = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    @FocusState private var focusedField: Field?

    private var passwordStrength: Int {
        guard !password.isEmpty else { return 0 }
        let isLong = password.count >= 8
        let isVeryLong = password.count >= 12
        let hasVariety = password.contains(where: \.isNumber) ||
                         password.contains(where: \.isUppercase) ||
                         password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.?".contains($0) })
        if isVeryLong && hasVariety { return 3 }
        if isLong || hasVariety { return 2 }
        return 1
    }

    private var passwordStrengthColor: Color {
        switch passwordStrength {
        case 1: return .red
        case 2: return .orange
        default: return .green
        }
    }

    private var passwordStrengthLabel: LocalizedStringKey {
        switch passwordStrength {
        case 1: return "Weak"
        case 2: return "Fair"
        default: return "Strong"
        }
    }

    private var passwordsMatch: Bool { password == confirmPassword }

    private var inputFieldsAreEmpty: Bool {
        username.isEmpty || name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty
    }

    private var inputFieldsAreValid: Bool {
        username.count >= 3 &&
        email.contains("@") &&
        passwordsMatch &&
        password.count >= 5 &&
        viewModel.errorMessage.isEmpty
    }

    private var errorText: String {
        if username.count < 3 {
            return String(localized: .usernameShouldHaveAtLeast3Symbols)
        } else if email.isEmpty || !email.contains("@") {
            return String(localized: .pleaseEnterAValidEmailAddress)
        } else if !passwordsMatch {
            return String(localized: .makeSureBothPasswordFieldsAreTheSame)
        } else if password.count < 5 {
            return String(localized: .yourPasswordShouldHaveAtLeast5Symbols)
        } else if !viewModel.errorMessage.isEmpty {
            return viewModel.errorMessage
        } else {
            return ""
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                errorBanner
                profileSection
                emailSection
                passwordSection
                signUpButton
            }
            .padding(.bottom, 32)
        }
        .onChange(of: viewModel.registeredUser) { _, newValue in
            guard newValue != nil else { return }
            showEmailSentAlert = true
        }
        .alert(Text(.checkYourEmail), isPresented: $showEmailSentAlert) {
            Button {
                guard let user = viewModel.registeredUser else { return }
                habits.forEach { $0.isSyncable = true }
                HapticManager.trigger(.success)
                userManager.profile = LocalUser(
                    id: user.id,
                    username: user.username,
                    name: user.name,
                    email: user.email,
                    isSignedInToServer: true,
                    isEmailVerified: user.isEmailVerified
                )
                appState.isAuthenticated = true
                context.insert(user.toSwiftData())
                context.saveOrLog()
                dismiss()
            } label: {
                Text(.gotIt)
            }
        } message: {
            Text(.weSentAConfirmationLinkToYouCanStartUsingHabitHuddleRightAwayAndVerifyLater(email))
        }
        .navigationTitle(String(localized: .registration))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 16)
            Text(.createAccount)
                .font(.title2.bold())
            Text(.syncYourHabitsAndConnectWithFriends)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var errorBanner: some View {
        if registerButtonPressed && !errorText.isEmpty {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.subheadline)
                Text(errorText)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private var profileSection: some View {
        formCard {
            fieldRow(icon: "at", color: .blue) {
                TextField(String(localized: .enterYourUsername), text: $username)
                    .textInputAutocapitalization(.never)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .name }
            }
            cardDivider
            fieldRow(icon: "person.fill", color: .orange) {
                TextField(String(localized: .enterYourName), text: $name)
                    .textContentType(.name)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
            }
        }
    }

    private var emailSection: some View {
        formCard {
            fieldRow(icon: "envelope.fill", color: .green) {
                TextField(String(localized: .enterYourEmail), text: $email)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }
        }
    }

    private var passwordSection: some View {
        formCard {
            fieldRow(icon: "lock.fill", color: .purple) {
                Group {
                    if showPassword {
                        TextField(String(localized: .enterYourPassword), text: $password)
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField(String(localized: .enterYourPassword), text: $password)
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                }
            }

            if !password.isEmpty {
                strengthBar
            }

            cardDivider

            fieldRow(icon: "lock.rotation", color: .purple) {
                Group {
                    if showConfirmPassword {
                        TextField(String(localized: .confirmYourPassword), text: $confirmPassword)
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField(String(localized: .confirmYourPassword), text: $confirmPassword)
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)
                .onSubmit { registerUser() }

                if !confirmPassword.isEmpty {
                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(passwordsMatch ? .green : .red)
                        .frame(width: 24)
                }

                Button {
                    showConfirmPassword.toggle()
                } label: {
                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                }
            }
        }
    }

    private var strengthBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i < passwordStrength ? passwordStrengthColor : Color(.systemFill))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.2), value: passwordStrength)
            }
            Text(passwordStrengthLabel)
                .font(.caption2.weight(.medium))
                .foregroundStyle(passwordStrengthColor)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .animation(.easeInOut(duration: 0.2), value: passwordStrength)
        }
        .padding(.leading, 52)
        .padding(.trailing, 16)
        .padding(.bottom, 8)
    }

    private var signUpButton: some View {
        Button {
            registerUser()
        } label: {
            Text(.signUp)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .background(inputFieldsAreEmpty ? Color.accentColor.opacity(0.4) : Color.accentColor)
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal)
        .disabled(inputFieldsAreEmpty)
        .animation(.easeInOut(duration: 0.15), value: inputFieldsAreEmpty)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal)
    }

    @ViewBuilder
    private func fieldRow<Content: View>(icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 28, height: 28)
                .foregroundStyle(.white)
                .background(color.gradient)
                .clipShape(.rect(cornerRadius: 7))
                .padding(.leading, 12)

            content()
        }
        .frame(minHeight: 48)
        .padding(.vertical, 2)
        .padding(.trailing, 12)
    }

    private var cardDivider: some View {
        Divider().padding(.leading, 52)
    }

    // MARK: - Actions

    private func registerUser() {
        withAnimation { registerButtonPressed = true }
        if inputFieldsAreValid {
            Task {
                try await viewModel.registerUser(
                    userID: userManager.profile.id,
                    username: username,
                    name: name,
                    email: email,
                    password: password
                )
            }
        }
    }
}

#Preview {
    RegistrationView()
}

//
//  ResetPasswordView.swift
//  HabitHuddle-iOS
//

import SwiftUI

struct ResetPasswordView: View {

    enum Field {
        case password, confirmPassword
    }

    let token: String

    @Environment(\.dismiss) private var dismiss

    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var submitPressed = false
    @State private var showSuccessAlert = false

    @FocusState private var focusedField: Field?

    @StateObject private var viewModel = ViewModel()

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
        password.isEmpty || confirmPassword.isEmpty
    }

    private var inputFieldsAreValid: Bool {
        passwordsMatch && password.count >= 5 && viewModel.errorMessage.isEmpty
    }

    private var errorText: String {
        if !passwordsMatch {
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
                passwordSection
                submitButton
            }
            .padding(.bottom, 32)
        }
        .onChange(of: viewModel.didResetPassword) { _, newValue in
            if newValue {
                HapticManager.trigger(.success)
                showSuccessAlert = true
            }
        }
        .alert(Text(.passwordUpdated), isPresented: $showSuccessAlert) {
            Button {
                dismiss()
            } label: {
                Text(.gotIt)
            }
        } message: {
            Text(.yourPasswordHasBeenChangedYouCanNowSignInWithYourNewPassword)
        }
        .navigationTitle(String(localized: .newPassword))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 16)
            Text(.chooseANewPassword)
                .font(.title2.bold())
            Text(.enterAndConfirmYourNewPassword)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var errorBanner: some View {
        if submitPressed && !errorText.isEmpty {
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
                .onSubmit { submit() }

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

    private var submitButton: some View {
        Button {
            submit()
        } label: {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .tint(.white)
                }
                Text(.updatePassword)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
        }
        .background(inputFieldsAreEmpty || viewModel.isSubmitting ? Color.accentColor.opacity(0.4) : Color.accentColor)
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal)
        .disabled(inputFieldsAreEmpty || viewModel.isSubmitting)
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

    private func submit() {
        focusedField = nil
        withAnimation { submitPressed = true }
        guard inputFieldsAreValid else { return }
        Task {
            await viewModel.resetPassword(token: token, newPassword: password)
        }
    }
}

#Preview {
    NavigationStack {
        ResetPasswordView(token: "preview-token")
    }
}

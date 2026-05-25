//
//  ChangePasswordView.swift
//  HabitHuddle-iOS
//

import SwiftUI

struct ChangePasswordView: View {

    enum Field {
        case current, new, confirm
    }

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = AccountSettingsViewModel()

    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showCurrent: Bool = false
    @State private var showNew: Bool = false
    @State private var showConfirm: Bool = false
    @State private var showSuccessAlert: Bool = false

    @FocusState private var focused: Field?

    private var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    private var disabled: Bool {
        viewModel.isSubmitting
            || currentPassword.isEmpty
            || newPassword.count < 5
            || !passwordsMatch
            || newPassword == currentPassword
    }

    private var passwordStrength: Int {
        guard !newPassword.isEmpty else { return 0 }
        let isLong = newPassword.count >= 8
        let isVeryLong = newPassword.count >= 12
        let hasVariety = newPassword.contains(where: \.isNumber) ||
                         newPassword.contains(where: \.isUppercase) ||
                         newPassword.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.?".contains($0) })
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

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                FormHeader(
                    icon: "lock.rotation",
                    title: .changePassword,
                    subtitle: .enterYourCurrentPasswordToAuthorizeThisChange
                )

                FormErrorBanner(message: viewModel.errorMessage)

                FormCard {
                    passwordField(
                        title: .enterYourCurrentPassword,
                        text: $currentPassword,
                        show: $showCurrent,
                        field: .current,
                        next: .new,
                        icon: "key.fill",
                        textContentType: .password
                    )
                }

                FormCard {
                    passwordField(
                        title: .enterYourNewPassword,
                        text: $newPassword,
                        show: $showNew,
                        field: .new,
                        next: .confirm,
                        icon: "lock.fill",
                        textContentType: .newPassword
                    )

                    if !newPassword.isEmpty {
                        strengthBar
                    }

                    FormCardDivider()

                    passwordField(
                        title: .confirmYourPassword,
                        text: $confirmPassword,
                        show: $showConfirm,
                        field: .confirm,
                        next: nil,
                        icon: "lock.rotation",
                        textContentType: .newPassword,
                        trailing: AnyView(matchIndicator)
                    )
                }

                FormPrimaryButton(
                    title: .updatePassword,
                    isLoading: viewModel.isSubmitting,
                    disabled: disabled,
                    action: submit
                )
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(String(localized: .changePassword))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            focused = .current
        }
        .onChange(of: viewModel.lastUpdatedUser) { _, newValue in
            if newValue != nil {
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
    }

    // MARK: - Field

    @ViewBuilder
    private func passwordField(
        title: LocalizedStringResource,
        text: Binding<String>,
        show: Binding<Bool>,
        field: Field,
        next: Field?,
        icon: String,
        textContentType: UITextContentType,
        trailing: AnyView? = nil
    ) -> some View {
        FormFieldRow(icon: icon, color: .purple) {
            Group {
                if show.wrappedValue {
                    TextField(String(localized: title), text: text)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } else {
                    SecureField(String(localized: title), text: text)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .focused($focused, equals: field)
            .submitLabel(next == nil ? .done : .next)
            .onSubmit {
                if let next { focused = next } else { submit() }
            }

            trailing

            Button {
                show.wrappedValue.toggle()
            } label: {
                Image(systemName: show.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
            }
        }
    }

    private var matchIndicator: some View {
        Group {
            if !confirmPassword.isEmpty {
                Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(passwordsMatch ? .green : .red)
                    .frame(width: 24)
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

    private func submit() {
        focused = nil
        Task {
            await viewModel.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )
        }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
    }
}

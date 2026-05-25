//
//  ForgotPasswordView.swift
//  HabitHuddle-iOS
//

import SwiftUI

struct ForgotPasswordView: View {

    enum Field {
        case email
    }

    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var showConfirmation = false

    @FocusState private var focusedField: Field?

    @StateObject private var viewModel = ViewModel()

    private var emailIsEmpty: Bool {
        email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                errorBanner
                emailSection
                sendButton
            }
            .padding(.bottom, 32)
        }
        .onChange(of: viewModel.didRequestReset) { _, newValue in
            if newValue {
                HapticManager.trigger(.success)
                showConfirmation = true
            }
        }
        .alert(Text(.checkYourEmail), isPresented: $showConfirmation) {
            Button {
                dismiss()
            } label: {
                Text(.gotIt)
            }
        } message: {
            Text(.ifAnAccountExistsForThisEmailWeveSentInstructionsToResetYourPassword)
        }
        .navigationTitle(String(localized: .forgotPassword))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "key.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 16)
            Text(.resetYourPassword)
                .font(.title2.bold())
            Text(.enterYourEmailAndWellSendYouALinkToResetYourPassword)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var errorBanner: some View {
        if !viewModel.errorMessage.isEmpty {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.subheadline)
                Text(viewModel.errorMessage)
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

    private var emailSection: some View {
        formCard {
            fieldRow(icon: "envelope.fill", color: .green) {
                TextField(String(localized: .enterYourEmail), text: $email)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.send)
                    .onSubmit { submit() }
            }
        }
    }

    private var sendButton: some View {
        Button {
            submit()
        } label: {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .tint(.white)
                }
                Text(.sendResetLink)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
        }
        .background(emailIsEmpty || viewModel.isSubmitting ? Color.accentColor.opacity(0.4) : Color.accentColor)
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal)
        .disabled(emailIsEmpty || viewModel.isSubmitting)
        .animation(.easeInOut(duration: 0.15), value: emailIsEmpty)
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

    // MARK: - Actions

    private func submit() {
        focusedField = nil
        Task {
            await viewModel.requestReset(email: email)
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}

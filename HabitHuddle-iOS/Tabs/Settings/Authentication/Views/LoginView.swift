//
//  LoginView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftData
import SwiftUI

struct LoginView: View {

    enum Field {
        case username, password
    }

    @Query var habits: [Habit]
    @Query var users: [User]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false

    @FocusState private var focusedField: Field?

    @EnvironmentObject private var userManager: LocalUserManager
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = LoginViewModel()

    @State private var showHabitsFound = false
    @State private var newServerHabits = [HabitDTO]()

    private var inputFieldIsEmpty: Bool {
        username.isEmpty || password.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    errorBanner
                    credentialsSection
                    signInButton
                    forgotPasswordLink
                }
                .padding(.bottom, 32)
            }
            .onChange(of: viewModel.loadedUser) { _, newValue in
                if newValue.createdAt != nil {
                    habits.forEach { $0.isSyncable = true }
                    HapticManager.trigger(.success)
                    appState.isAuthenticated = true
                    userManager.profile = LocalUser(
                        id: newValue.id,
                        username: newValue.username,
                        name: newValue.name,
                        email: newValue.email,
                        isSignedInToServer: true,
                        isEmailVerified: newValue.isEmailVerified,
                        authProvider: newValue.authProvider
                    )
                    dismiss()
                    if !users.contains(where: { $0.id == newValue.id }) {
                        context.insert(newValue.toSwiftData())
                        context.saveOrLog()
                    }
                }
            }
            .onChange(of: viewModel.loadedHabits) { _, newValue in
                let existingHabitIds = Set(habits.map { $0.id })
                newServerHabits = viewModel.loadedHabits.filter { !existingHabitIds.contains($0.id) }
                showHabitsFound = !newServerHabits.isEmpty
            }
            .alert(String(localized: .habitsFound), isPresented: $showHabitsFound) {
                Button(String(localized: .deleteOnServer), role: .destructive) {
                    Task {
                        await viewModel.deleteHabits(with: newServerHabits.map { $0.id })
                    }
                }
                Button(String(localized: .saveLocally)) {
                    for loadedHabit in newServerHabits {
                        _ = loadedHabit.saved(in: context)
                    }
                    context.saveOrLog()
                }
            } message: {
                let list = newServerHabits.map { "• \($0.name)" }.joined(separator: "\n")
                Text("We found the following habits on the server that you previously created:\n\n\(list)\n\nWould you like to save them locally or delete them from the server?")
            }
            .navigationTitle(String(localized: .login))
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 16)
            Text(.welcomeBack)
                .font(.title2.bold())
            Text(.signInToSyncYourHabits)
                .font(.subheadline)
                .foregroundStyle(.secondary)
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

    private var credentialsSection: some View {
        formCard {
            fieldRow(icon: "at", color: .blue) {
                TextField(String(localized: .enterYourUsername), text: $username)
                    .textInputAutocapitalization(.never)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }
            cardDivider
            fieldRow(icon: "lock.fill", color: .purple) {
                Group {
                    if showPassword {
                        TextField(String(localized: .enterYourPassword), text: $password)
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField(String(localized: .enterYourPassword), text: $password)
                            .textContentType(.password)
                    }
                }
                .focused($focusedField, equals: .password)
                .submitLabel(.done)
                .onSubmit { loginUser() }

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                }
            }
        }
    }

    private var signInButton: some View {
        Button {
            loginUser()
        } label: {
            Text(.signIn)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .background(inputFieldIsEmpty ? Color.accentColor.opacity(0.4) : Color.accentColor)
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal)
        .disabled(inputFieldIsEmpty)
        .animation(.easeInOut(duration: 0.15), value: inputFieldIsEmpty)
    }

    private var forgotPasswordLink: some View {
        NavigationLink {
            ForgotPasswordView()
        } label: {
            Text(.forgotPassword)
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
        }
        .padding(.top, 4)
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

    private func loginUser() {
        Task {
            await viewModel.loginUser(username: username, password: password)
        }
    }
}

#Preview {
    LoginView()
}

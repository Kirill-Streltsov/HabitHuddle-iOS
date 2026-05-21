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
        case username
        case name
        case password
        case confirmPassword
    }

    @Query
    var habits: [Habit]

    @StateObject private var viewModel = ViewModel()

    @EnvironmentObject var userManager: LocalUserManager
    @EnvironmentObject var appState: AppState

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var registerButtonPressed = false

    @FocusState private var focusedField: Field?

    private var inputFieldsAreEmpty: Bool {
        username.isEmpty || name.isEmpty || password.isEmpty || confirmPassword.isEmpty
    }

    private var inputFieldsAreValid: Bool {
        return username.count >= 3 && password == confirmPassword && password.count >= 5 && viewModel.errorMessage.isEmpty
    }

    private var errorText: String {
        if username.count < 3 {
            return String(localized: .usernameShouldHaveAtLeast3Symbols)
        } else if password != confirmPassword {
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
            Image(systemName: "person.badge.plus")
                .font(.system(size: 75))
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 12) {
                ErrorText(text: errorText)
                    .opacity(registerButtonPressed ? 1 : 0)
                    .frame(height: 20)

                InputView(text: $username, title: .username, placeholder: .enterYourUsername)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)

                InputView(text: $name, title: .name, placeholder: .enterYourName)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)

                InputView(text: $password, title: .password, placeholder: .enterYourPassword, isSecureField: false)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)

                InputView(text: $confirmPassword, title: .confirmPassword, placeholder: .confirmYourPassword, isSecureField: false)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.done)
            }
            .onSubmit {
                switch focusedField {
                case .username:
                    focusedField = .name
                case .name:
                    focusedField = .password
                case .password:
                    focusedField = .confirmPassword
                case .confirmPassword:
                    registerUser()
                default:
                    print("❌ Error: Some unknown focus state in registration")
                }
            }
            .padding(.horizontal)
            .padding(12)

            Button {
                registerUser()
            } label: {
                Text(.signUp)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .disabled(inputFieldsAreEmpty)
            .background(inputFieldsAreEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor)
            .clipShape(.rect(cornerRadius: 10))
            .padding(.horizontal, 16)
            Spacer()
        }
        .onChange(of: viewModel.loadedUser) { _, newValue in
            if newValue.createdAt != nil {
                habits.forEach { $0.isSyncable = true }
                HapticManager.trigger(.success)
                appState.isAuthenticated = true
                userManager.profile = LocalUser(id: newValue.id, username: newValue.username, name: newValue.name, isSignedInToServer: true)
                dismiss()
                context.insert(newValue.toSwiftData())
                context.saveOrLog()
            }
        }
        .navigationTitle(String(localized: .registration))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private func registerUser() {
        registerButtonPressed = true
        if inputFieldsAreValid {
            Task {
                try await viewModel.registerUser(userID: userManager.profile.id, username: username, name: name, password: password)
            }
        }
    }
}

#Preview {
    RegistrationView()
}

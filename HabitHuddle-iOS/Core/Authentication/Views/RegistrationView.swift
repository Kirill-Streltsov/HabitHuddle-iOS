//
//  RegistrationView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftData
import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject var userManager: LocalUserManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var signUpTapped = false

    private var inputFieldsAreEmpty: Bool {
        username.isEmpty || name.isEmpty || password.isEmpty || confirmPassword.isEmpty
    }

    private var inputFieldsAreValid: Bool {
        return username.count >= 3 && password == confirmPassword && password.count >= 5 && viewModel.errorMessage.isEmpty
    }

    private var errorText: String {
        if username.count < 3 {
            return "Username should have at least 3 symbols"
        } else if password != confirmPassword {
            return "Make sure both password fields are the same"
        } else if password.count < 5 {
            return "Your password should have at least 5 symbols"
        } else if !viewModel.errorMessage.isEmpty {
            return viewModel.errorMessage
        } else {
            return ""
        }
    }

    init(appState: AppState, userManager: LocalUserManager) {
        _viewModel = StateObject(wrappedValue: ViewModel(appState: appState, userManager: userManager))
    }

    var body: some View {
        VStack {
            VStack(spacing: 24) {
                Text("Create an account")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 75))
            }
            .foregroundStyle(Color.accentColor)
            .frame(height: 160)

            VStack(alignment: .leading, spacing: 24) {
                ErrorText(text: errorText)
                    .opacity(signUpTapped ? 1 : 0)
                    .frame(height: 20)

                InputView(text: $username, title: "Username", placeholder: "Enter your username...")
                    .textInputAutocapitalization(.never)

                InputView(text: $name, title: "Name", placeholder: "Enter your name...")

                InputView(text: $password, title: "Password", placeholder: "Enter your password...", isSecureField: false)
                InputView(text: $confirmPassword, title: "Confirm password", placeholder: "Confirm your password...", isSecureField: false)
            }
            .padding(.horizontal)
            .padding(12)

            Button {
                signUpTapped = true
                if inputFieldsAreValid {
                    Task {
                        let result = try await viewModel.registerUser(username: username, name: name, password: password, context: context)
                        handleResult(result) { codableUser in
                            userManager.profile = LocalUser(id: codableUser.id, username: codableUser.username, name: codableUser.name)
                            dismiss()
                        } onFailure: { error in
                            print("❌ Couldn't load the user after registration - no response")
                        }
                    }
                }
            } label: {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .disabled(inputFieldsAreEmpty)
            .background(inputFieldsAreEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor)
            .clipShape(.rect(cornerRadius: 10))
            .padding(.top, 24)

            Spacer()
        }
    }
}

#Preview {
    RegistrationView(appState: AppState(), userManager: LocalUserManager())
}

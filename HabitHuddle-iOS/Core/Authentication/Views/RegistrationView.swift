//
//  RegistrationView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftUI

struct RegistrationView: View {
    
    @State var viewModel: ViewModel?
    @EnvironmentObject var appState: AppState

    @State private var username = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var signUpTapped = false
    @Environment(\.dismiss) var dismiss

    private var inputFieldIsEmpty: Bool {
        username.isEmpty || name.isEmpty || password.isEmpty || confirmPassword.isEmpty
    }

    private var errorText: String {
        if username.count < 3 {
            return "Username should have at least 3 symbols"
        } else if password != confirmPassword {
            return "Make sure both password fields are the same"
        } else if password.count < 5 {
            return "Your password should have at least 5 symbols"
        } else if let viewModel = viewModel, !viewModel.errorMessage.isEmpty {
            return viewModel.errorMessage
        } else {
            return " "
        }
    }

    var body: some View {
        VStack {
            Text("Create an account")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .frame(height: 160)
                .foregroundStyle(Color(.systemBlue))

            VStack(alignment: .leading, spacing: 24) {
                ErrorText(text: errorText)
                    .opacity(signUpTapped ? 1 : 0)

                InputView(text: $username, title: "Username", placeholder: "Enter your username...")
                    .textInputAutocapitalization(.never)

                InputView(text: $name, title: "Name", placeholder: "Enter your name...")

                InputView(text: $password, title: "Password", placeholder: "Enter your password...", isSecureField: false)
                InputView(text: $confirmPassword, title: "Confirm password", placeholder: "Confirm your password...", isSecureField: false)
            }
            .padding(.horizontal)
            .padding(12)

            Button {
                Task {
                    await viewModel?.registerUser(username: username, name: name, password: password)
                }
            } label: {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .disabled(inputFieldIsEmpty)
            .background(inputFieldIsEmpty ? Color(.systemBlue).opacity(0.5) : Color(.systemBlue))
            .clipShape(.rect(cornerRadius: 10))
            .padding(.top, 24)

            Spacer()

            Button {
                dismiss()
            } label: {
                HStack(spacing: 2) {
                    Text("Already have an account?")
                    Text("Sign in")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ViewModel(appState: appState)
            }
        }
    }
}

#Preview {
    RegistrationView()
}

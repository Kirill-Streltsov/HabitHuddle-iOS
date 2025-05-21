//
//  LoginView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @StateObject private var viewModel: ViewModel

    @State private var username = ""
    @State private var password = ""
    private var inputFieldIsEmpty: Bool {
        username.isEmpty || password.isEmpty
    }
    
    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Log into your account")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .frame(height: 160)
                    .foregroundStyle(Color(.systemBlue))

                VStack(alignment: .leading, spacing: 24) {
                    ErrorText(text: viewModel.errorMessage)
                        .frame(height: 20)

                    InputView(text: $username,
                              title: "Username",
                              placeholder: "Enter your username...")
                        .textInputAutocapitalization(.never)

                    InputView(text: $password, title: "Password", placeholder: "Enter your password...", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(12)

                Button {
                    Task {
                        await viewModel.loginUser(username: username, password: password)
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
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

                NavigationLink {
                    let registrationViewModel = RegistrationView.ViewModel(appState: viewModel.appState, modelContext: viewModel.modelContext)
                    RegistrationView(viewModel: registrationViewModel)
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 2) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 15))
                }
            }
        }
    }
}

#Preview {
    LoginView(viewModel: LoginView.ViewModel(appState: AppState(), modelContext: ModelContainer.preview.mainContext))
}

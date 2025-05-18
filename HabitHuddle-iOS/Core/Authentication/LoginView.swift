//
//  LoginView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    private var inputFieldIsEmpty: Bool {
        username.isEmpty || password.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Log into your account")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .frame(height: 160)
                    .foregroundStyle(Color(.systemBlue))

                VStack(spacing: 24) {
                    InputView(text: $username,
                              title: "Username",
                              placeholder: "Enter your username...")
                        .textInputAutocapitalization(.never)

                    InputView(text: $password, title: "Password", placeholder: "Enter your password...", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(12)

                Button {
                    print("Log user in...")
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
                    RegistrationView()
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
    LoginView()
}

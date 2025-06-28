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
        case username
        case password
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    
    @FocusState private var focusedField: Field?
    
    @EnvironmentObject private var viewModel: LoginViewModel
    
    private var inputFieldIsEmpty: Bool {
        username.isEmpty || password.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Image(systemName: "person.fill")
                    .font(.system(size: 75))
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 12) {
                    ErrorText(text: viewModel.errorMessage)
                        .frame(height: 20)
                    

                    InputView(text: $username,
                              title: "Username",
                              placeholder: "Enter your username...")
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .username)
                        .submitLabel(.next)

                    InputView(text: $password, title: "Password", placeholder: "Enter your password...", isSecureField: true)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                }
                .onSubmit {
                    switch focusedField {
                    case .username:
                        focusedField = .password
                    case .password:
                        loginUser()
                    default:
                        print("❌ Error: Some unknown focus state in registration")
                    }
                }
                .padding(.horizontal)
                .padding(12)
                
                Button {
                    loginUser()
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .disabled(inputFieldIsEmpty)
                .background(inputFieldIsEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor)
                .clipShape(.rect(cornerRadius: 10))

                Spacer()
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
    
    
    private func loginUser() {
        Task {
            await viewModel.loginUser(username: username, password: password, using: context)
            dismiss()
        }
    }    
}

#Preview {
    LoginView()
}

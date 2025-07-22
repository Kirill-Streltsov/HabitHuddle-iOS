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

    var body: some View {
        ScrollView {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 75))
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 12) {
                ErrorText(text: errorText)
                    .opacity(registerButtonPressed ? 1 : 0)
                    .frame(height: 20)

                InputView(text: $username, title: "Username", placeholder: "Enter your username...")
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)

                InputView(text: $name, title: "Name", placeholder: "Enter your name...")
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)

                InputView(text: $password, title: "Password", placeholder: "Enter your password...", isSecureField: false)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                
                InputView(text: $confirmPassword, title: "Confirm password", placeholder: "Confirm your password...", isSecureField: false)
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
                try? context.save()
            }
        }
        .navigationTitle("Registration")
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

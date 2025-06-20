//
//  LoginView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftData
import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct LoginView: View {
    
    enum Field {
        case username
        case password
    }
    
    @StateObject private var viewModel: ViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    
    @FocusState private var focusedField: Field?
    
    private var inputFieldIsEmpty: Bool {
        username.isEmpty || password.isEmpty
    }

    init(appState: AppState, userManager: LocalUserManager) {
        _viewModel = StateObject(wrappedValue: ViewModel(appState: appState, userManager: userManager))
    }

    var body: some View {
        NavigationStack {
            VStack {
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

                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide)) {
                    Task {
                        if let user = await viewModel.handleGoogleSignIn() {
                            handleUserResponse(user: user)
                        }
                    }
                }
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                

                Spacer()
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    private func loginUser() {
        Task {
            if let user = await viewModel.loginUser(username: username, password: password) {
                handleUserResponse(user: user)
            }
        }
    }
    
    private func handleUserResponse(user: UserDTO) {
        Task {
            print("TOKEN: \(String(describing: TokenManager.token))")
            let codableHabitsResult = await viewModel.getUserHabits()
            Helpers.handleResult(codableHabitsResult) { codableHabits in
                saveHabitsLocally(codableHabits)
                viewModel.saveUser(user, using: context)
                print("TOKEN: \(TokenManager.token)")
                dismiss()
            } onFailure: { apiError in
                print("❌ Error: Could not load user habits: \(apiError.localizedDescription)")
            }
        }
    }

    private func saveHabitsLocally(_ codableHabits: [HabitDTO]) {
        for codableHabit in codableHabits {
            // Skip if habit with same ID already exists
            if habitExists(withId: codableHabit.id) {
                continue
            }

            let habit = Habit(
                id: codableHabit.id,
                user: codableHabit.user,
                name: codableHabit.name,
                description: codableHabit.description,
                duration: codableHabit.duration
            )

            codableHabit.checkIns?.forEach { _ in
                let checkIn = HabitCheckIn(habit: habit)
                context.insert(checkIn)
            }

            context.insert(habit)
        }
    }
    
    private func habitExists(withId id: UUID) -> Bool {
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == id })
        return (try? context.fetchCount(descriptor)) ?? 0 > 0
    }
}

#Preview {
    LoginView(appState: AppState(), userManager: LocalUserManager())
}

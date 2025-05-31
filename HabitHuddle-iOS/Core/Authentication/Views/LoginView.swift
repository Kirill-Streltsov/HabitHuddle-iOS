//
//  LoginView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftData
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.modelContext) private var context

    @State private var username = ""
    @State private var password = ""
    private var inputFieldIsEmpty: Bool {
        username.isEmpty || password.isEmpty
    }

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: ViewModel(appState: appState))
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
                        if let cu = await viewModel.loginUser(username: username, password: password) {
                            print("TOKEN MANAGER: \(String(describing: TokenManager.token))")
                            let codableHabitsResult = await viewModel.getUserHabits()
                            handleResult(codableHabitsResult) { codableHabits in
                                saveHabitsLocally(codableHabits)
                                viewModel.saveUser(cu, using: context)
                            } onFailure: { apiError in
                                print("Could not load user habits: \(apiError.localizedDescription)")
                            }
                        }
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
                    RegistrationView(appState: viewModel.appState)
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
    
    private func saveHabitsLocally(_ codableHabits: [CodableHabit]) {
        for codableHabit in codableHabits {
            let habit = Habit(
                id: codableHabit.id,
                user: codableHabit.user,
                name: codableHabit.name,
                description: codableHabit.description,
                duration: codableHabit.duration,
            )
            codableHabit.checkIns?.forEach { _ in
                let checkIn = HabitCheckIn(habit: habit)
                context.insert(checkIn)
            }
            context.insert(habit)
        }
    }
}

#Preview {
    LoginView(appState: AppState())
}

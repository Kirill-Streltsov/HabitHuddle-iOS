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
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    private var inputFieldIsEmpty: Bool {
        username.isEmpty || password.isEmpty
    }

    init(appState: AppState, userManager: LocalUserManager) {
        _viewModel = StateObject(wrappedValue: ViewModel(appState: appState, userManager: userManager))
    }

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 24) {
                    Text("Log into your account")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                    Image(systemName: "person.fill")
                        .font(.system(size: 75))
                }
                .foregroundStyle(Color.accentColor)
                .frame(height: 160)

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
                            print("TOKEN: \(String(describing: TokenManager.token))")
                            let codableHabitsResult = await viewModel.getUserHabits()
                            Helpers.handleResult(codableHabitsResult) { codableHabits in
                                saveHabitsLocally(codableHabits)
                                viewModel.saveUser(cu, using: context)
                                print("TOKEN: \(TokenManager.token)")
                                dismiss()
                            } onFailure: { apiError in
                                print("Could not load user habits: \(apiError.localizedDescription)")
                            }
                        }
                    }
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
                .padding(.top, 24)

                Spacer()
            }
        }
    }

    private func saveHabitsLocally(_ codableHabits: [HabitDTO]) {
        for codableHabit in codableHabits {
            // Skip if habit with same ID already exists
            if habitExists(withId: codableHabit.id) {
                print("HABIT WITH NAME \(codableHabit.name) ALREADY EXISTS")
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

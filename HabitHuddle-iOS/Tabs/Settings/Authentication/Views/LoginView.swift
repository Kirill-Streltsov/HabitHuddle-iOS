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
    
    @Query
    var habits: [Habit]
    
    @Query
    var users: [User]
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    
    @FocusState private var focusedField: Field?
    
    @EnvironmentObject private var userManager: LocalUserManager
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = LoginViewModel()
    
    @State private var showHabitsFound = false
    @State private var newServerHabits = [HabitDTO]()
    
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
            .onChange(of: viewModel.loadedUser) { _, newValue in
                if newValue.createdAt != nil {
                    habits.forEach { $0.isSyncable = true }
                    HapticManager.trigger(.success)
                    appState.isAuthenticated = true
                    userManager.profile = LocalUser(id: newValue.id, username: newValue.username, name: newValue.name, isSignedInToServer: true)
                    if !users.contains(where: { $0.id == newValue.id }) {
                        context.insert(newValue.toSwiftData())
                        try? context.save()
                    }
                }
            }
            .onChange(of: viewModel.loadedHabits) { _, newValue in
                let existingHabitIds = Set(habits.map { $0.id })
                newServerHabits = viewModel.loadedHabits.filter { !existingHabitIds.contains($0.id) }
                showHabitsFound = !newServerHabits.isEmpty
            }
            .alert("Habits Found", isPresented: $showHabitsFound) {
                Button("Delete on server", role: .destructive) {
                    Task {
                        await viewModel.deleteHabits(with: newServerHabits.map { $0.id })
                    }
                }
                Button("Save locally") {
                    for loadedHabit in newServerHabits {
                        _ = loadedHabit.saved(in: context)
                    }
                    try? context.save()
                }
            } message: {
                Text("""
                We found the following habits on the server that you previously created:\n
                \(newServerHabits.map { "• \($0.name)" }.joined(separator: "\n"))

                Would you like to save them locally or delete them from the server?
                """)
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }


    private func loginUser() {
        Task {
            await viewModel.loginUser(username: username, password: password)
        }
    }    
}

#Preview {
    LoginView()
}

//
//  SettingsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var userManager: LocalUserManager
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Label("Status", systemImage: "person.circle")
                        Spacer()
                        Text(appState.isAuthenticated ? "Signed In" : "Guest")
                            .foregroundStyle(.secondary)
                    }

                    if appState.isAuthenticated {
                            HStack {
                                Label("Your Username", systemImage: "person")
                                Spacer()
                                Text(userManager.profile.username)
                                    .foregroundStyle(.secondary)
                            }

                        Button(role: .destructive) {
                            withAnimation {
                                appState.logout(userManager: userManager)
                            }
                        } label: {
                            Label("Log Out", systemImage: "arrow.backward.square")
                        }
                    } else {
                        NavigationLink(destination: LoginView(appState: appState, userManager: userManager)) {
                            Label("Log In", systemImage: "person.fill")
                        }

                        NavigationLink(destination: RegistrationView(appState: appState, userManager: userManager)) {
                            Label("Register", systemImage: "person.badge.plus")
                        }
                        
                        Button {
                            Task {
                                if let user = await viewModel.handleGoogleSignIn() {
                                    handleUserResponse(user: user)
                                }
                            }
                        } label: {
                            Label {
                                Text("Sign in with Google")
                            } icon: {
                                Image("google")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                }

                Section(header: Text("Preferences")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }

                    NavigationLink(destination: Text("SUBSCRIPTIONS")) {
                        Label("Manage Subscription", systemImage: "star.fill")
                    }
                }

                Section(header: Text("Information")) {
                    NavigationLink(destination: Text("TERMS OF SERVICES")) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }

                    NavigationLink(destination: Text("PRIVACY POLICY")) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }

                    NavigationLink(destination: Text("ABOUT")) {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func handleUserResponse(user: UserDTO) {
        appState.isAuthenticated = true
        userManager.profile = LocalUser(id: user.id, username: user.username, name: user.name, isSignedInToServer: true)
        Task {
            print("TOKEN: \(String(describing: TokenManager.token))")
            let codableHabitsResult = await viewModel.getUserHabits()
            Helpers.handleResult(codableHabitsResult) { codableHabits in
                saveHabitsLocally(codableHabits)
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
                duration: codableHabit.duration,
                reminderTime: codableHabit.reminderTime
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
    SettingsView()
}

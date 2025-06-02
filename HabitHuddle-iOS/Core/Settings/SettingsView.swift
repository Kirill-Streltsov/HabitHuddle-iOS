//
//  SettingsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI


struct SettingsView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var userManager: LocalUserManager

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Label("Status", systemImage: "person.circle")
                        Spacer()
                        Text(appState.isAuthenticated ? "Signed In" : "Guest")
                            .foregroundColor(.secondary)
                    }

                    if appState.isAuthenticated {
                            HStack {
                                Label("Your Username", systemImage: "person")
                                Spacer()
                                Text(userManager.profile.username)
                                    .foregroundColor(.secondary)
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
}

#Preview {
    SettingsView()
}

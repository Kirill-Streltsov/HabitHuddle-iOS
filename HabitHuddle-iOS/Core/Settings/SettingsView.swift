//
//  SettingsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @Environment(\.modelContext) private var context
            
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var userManager: LocalUserManager
    
    @EnvironmentObject private var loginViewModel: LoginViewModel
    
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
                        NavigationLink(destination: LoginView()) {
                            Label("Log In", systemImage: "person.fill")
                        }

                        NavigationLink(destination: RegistrationView(appState: appState, userManager: userManager)) {
                            Label("Register", systemImage: "person.badge.plus")
                        }
                        
                        Button {
                            Task {
                                await loginViewModel.handleGoogleSignIn(using: context)
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
}

#Preview {
    SettingsView()
}

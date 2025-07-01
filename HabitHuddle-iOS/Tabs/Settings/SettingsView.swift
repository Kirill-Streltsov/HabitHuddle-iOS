//
//  SettingsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI
import SwiftData
import AuthenticationServices

struct SettingsView: View {
    
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
                            googleButtonLabel
                        }
                        .buttonStyle(.plain)
                        
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(with: result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 45)
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
    
    private var googleButtonLabel: some View {
        HStack {
            Image("google") // Add a Google logo asset named "google-icon" to Assets.xcassets
                .resizable()
                .frame(width: 30, height: 30)
            
            Text("Sign in with Google")
                .font(.system(size: 16, weight: .semibold))
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 45)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .cornerRadius(8)
    }
    
    func handleAppleSignIn(with result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let authResults):
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
               let tokenData = credential.identityToken,
               let tokenString = String(data: tokenData, encoding: .utf8) {
                
                let name: String
                
                
                if let givenName = credential.fullName?.givenName, let familyName = credential.fullName?.familyName {
                    name = "\(givenName) \(familyName)"
                } else {
                    name = ""
                }
                Task {
                    await loginViewModel.handleAppleSignIn(appleToken: tokenString, name: name, using: context)
                }
            }
        case .failure(let error):
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}

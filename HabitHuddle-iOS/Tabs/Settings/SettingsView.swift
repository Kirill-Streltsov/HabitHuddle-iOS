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

    @Query
    var habits: [Habit]

    @Query
    var users: [User]

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    @Environment(\.modelContext) private var context

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var userManager: LocalUserManager

    @StateObject private var viewModel = LoginViewModel()

    @State private var showHabitsFound = false
    @State private var newServerHabits = [HabitDTO]()

    var body: some View {
        NavigationStack {
            List {
                accountSection
                preferencesSection
                informationSection
                
                if appState.isAuthenticated {
                    Section {
                        SubmitButton(title: .deleteMyAccount, color: .red, iconName: "trash") {
                            HapticManager.trigger(.error)
                            Task {
                                let deleteResult = await viewModel.deleteMyAccount()
                                Helpers.handleResult(deleteResult) { status in
                                    if status == .ok {
                                        habits.forEach {
                                            $0.isSyncable = false
                                            $0.isPublic = false
                                            $0.challenges = []
                                        }
                                        print("✅ Successfully deleted the account. Status: \(status)")
                                        appState.logout(userManager: userManager)
                                        guard let currentUser = users.first(where: { $0.id == userManager.profile.id }) else { return }
                                        context.delete(currentUser)
                                        context.saveOrLog()
                                    }
                                } onFailure: { error in
                                    print("❌ Error: couldn't delete the account: \(error)")
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(String(localized: .settings))
        }
        .onChange(of: viewModel.loadedUser) { _, newValue in
            if newValue.createdAt != nil {
                habits.forEach { $0.isSyncable = true }
                HapticManager.trigger(.success)
                appState.isAuthenticated = true
                userManager.profile = LocalUser(id: newValue.id, username: newValue.username, name: newValue.name, isSignedInToServer: true)
                if !users.contains(where: { $0.id == newValue.id }) {
                    context.insert(newValue.toSwiftData())
                    context.saveOrLog()
                }
            }
        }
        .onChange(of: viewModel.loadedHabits) { _, newValue in
            let existingHabitIds = Set(habits.map { $0.id })
            newServerHabits = viewModel.loadedHabits.filter { !existingHabitIds.contains($0.id) }
            showHabitsFound = !newServerHabits.isEmpty
        }
        .alert(String(localized: .habitsFound),
               isPresented: $showHabitsFound) {
            Button(String(localized: .deleteOnServer), role: .destructive) {
                Task {
                    await viewModel.deleteHabits(with: newServerHabits.map { $0.id })
                }
            }
            Button(String(localized: .saveLocally)) {
                for loadedHabit in viewModel.loadedHabits {
                    let _ = loadedHabit.saved(in: context)
                }
                context.saveOrLog()
            }
        } message: {
            Text("""
            We found the following habits on the server that you previously created:\n
            \(newServerHabits.map { "• \($0.name)" }.joined(separator: "\n"))
            
            Would you like to save them locally or delete them from the server?
            """)
        }
    }
    
    private var accountSection: some View {
        Section(header: Text(.account)) {
            HStack {
                Label(String(localized: .status), systemImage: "person.circle")
                Spacer()
                appState.isAuthenticated ? Text(.signedIn) : Text(.guest)
                    .foregroundStyle(.secondary)
            }
            
            if appState.isAuthenticated {
                HStack {
                    Label(String(localized: .yourUsername), systemImage: "person")
                    Spacer()
                    Text(userManager.profile.username)
                        .foregroundStyle(.secondary)
                }
                
                Button(role: .destructive) {
                    handleLogout()
                } label: {
                    Label(String(localized: .logOut), systemImage: "arrow.backward.square")
                }
            } else {
                NavigationLink(destination: LoginView()) {
                    Label(String(localized: .logIn), systemImage: "person.fill")
                }
                
                NavigationLink(destination: RegistrationView()) {
                    Label(String(localized: .register), systemImage: "person.badge.plus")
                }
                
                Button {
                    Task {
                        await viewModel.handleGoogleSignIn()
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
    }
    
    private var preferencesSection: some View {
        Section(header: Text(.preferences)) {
            Toggle(isOn: $isDarkMode) {
                Label(String(localized: .darkMode), systemImage: "moon.fill")
            }

            NavigationLink(destination: Text("SUBSCRIPTIONS")) {
                Label(String(localized: .manageSubscription), systemImage: "star.fill")
            }
        }
    }
    
    private var informationSection: some View {
        Section(header: Text(.information)) {
            NavigationLink(destination: Text(.termsOfService)) {
                Label(String(localized: .termsOfService), systemImage: "doc.text")
            }

            NavigationLink(destination: Text(.privacyPolicy)) {
                Label(String(localized: .privacyPolicy), systemImage: "lock.shield")
            }

            NavigationLink(destination: Text(.about)) {
                Label(String(localized: .about), systemImage: "info.circle")
            }
        }
    }
    
    private var googleButtonLabel: some View {
        HStack {
            Image("google")
                .resizable()
                .frame(width: 30, height: 30)
            
            Text(.signInWithGoogle)
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
    
    func handleLogout() {
        Task {
            let logoutResult = await viewModel.logout()
            Helpers.handleResult(logoutResult) { status in
                if status == .ok {
                    withAnimation {
                        viewModel.loadedUser = UserDTO(id: UUID(), username: "", name: "", createdAt: nil, updatedAt: nil)
                        viewModel.loadedHabits = []
                        appState.logout(userManager: userManager)
                        habits.forEach {
                            $0.isSyncable = false
                            $0.isPublic = false
                            $0.challenges = []
                        }
                        guard let currentUser = users.first(where: { $0.id == userManager.profile.id }) else { return }
                        context.delete(currentUser)
                        context.saveOrLog()
                    }
                }
            } onFailure: { _ in
                // TODO: show error alert
            }
        }
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
                    await viewModel.handleAppleSignIn(appleToken: tokenString, name: name)
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

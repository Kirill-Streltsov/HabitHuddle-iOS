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

    @StateObject private var viewModel = LoginViewModel()

    @State private var showHabitsFound = false
    @State private var newServerHabits = [HabitDTO]()
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false

    var body: some View {
        settingsContent
            .alert(String(localized: .areYouSure), isPresented: $showLogoutAlert) {
                Button(String(localized: .logOut), role: .destructive) { handleLogout() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(.youWillBeSignedOutOfYourAccount)
            }
            .alert(String(localized: .areYouSure), isPresented: $showDeleteAccountAlert) {
                Button(String(localized: .deleteMyAccount), role: .destructive) { performDeleteAccount() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(.thisWillPermanentlyDeleteYourAccountAndAllAssociatedData)
            }
    }

    private var settingsContent: some View {
        NavigationStack {
            List {
                accountSection
                preferencesSection
                informationSection

                if appState.isAuthenticated {
                    Section {
                        SubmitButton(title: .deleteMyAccount, color: .red, iconName: "trash") {
                            showDeleteAccountAlert = true
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
                fetchHabits().forEach { $0.isSyncable = true }
                HapticManager.trigger(.success)
                appState.isAuthenticated = true
                userManager.profile = LocalUser(
                    id: newValue.id,
                    username: newValue.username,
                    name: newValue.name,
                    email: newValue.email,
                    isSignedInToServer: true,
                    isEmailVerified: newValue.isEmailVerified,
                    authProvider: newValue.authProvider
                )
                if !fetchUsers().contains(where: { $0.id == newValue.id }) {
                    context.insert(newValue.toSwiftData())
                    context.saveOrLog()
                }
            }
        }
        .onChange(of: viewModel.loadedHabits) { _, _ in
            let existingHabitIds = Set(fetchHabits().map { $0.id })
            newServerHabits = viewModel.loadedHabits.filter { !existingHabitIds.contains($0.id) }
            showHabitsFound = !newServerHabits.isEmpty
        }
        .alert(String(localized: .habitsFound), isPresented: $showHabitsFound) {
            Button(String(localized: .deleteOnServer), role: .destructive) {
                Task { await viewModel.deleteHabits(with: newServerHabits.map { $0.id }) }
            }
            Button(String(localized: .saveLocally)) {
                for loadedHabit in viewModel.loadedHabits {
                    let _ = loadedHabit.saved(in: context)
                }
                context.saveOrLog()
            }
        } message: {
            let list = newServerHabits.map { "• \($0.name)" }.joined(separator: "\n")
            Text("We found the following habits on the server that you previously created:\n\n\(list)\n\nWould you like to save them locally or delete them from the server?")
        }
    }

    private func performDeleteAccount() {
        HapticManager.trigger(.error)
        Task {
            let deleteResult = await viewModel.deleteMyAccount()
            Helpers.handleResult(deleteResult) { status in
                if status == .ok {
                    fetchHabits().forEach {
                        $0.isSyncable = false
                        $0.isPublic = false
                        $0.challenges = []
                    }
                    print("✅ Successfully deleted the account. Status: \(status)")
                    appState.logout(userManager: userManager)
                    guard let currentUser = fetchUsers().first(where: { $0.id == userManager.profile.id }) else { return }
                    context.delete(currentUser)
                    context.saveOrLog()
                }
            } onFailure: { error in
                print("❌ Error: couldn't delete the account: \(error)")
            }
        }
    }
    
    private var accountSection: some View {
        Section(header: Text(.account)) {
            HStack {
                settingsIcon("person.circle", color: .blue)
                Text(.status)
                Spacer()
                appState.isAuthenticated ? Text(.signedIn) : Text(.guest)
                    .foregroundStyle(.secondary)
            }

            if appState.isAuthenticated {
                HStack {
                    settingsIcon("person", color: .blue)
                    Text(.yourUsername)
                    Spacer()
                    Text(userManager.profile.username)
                        .foregroundStyle(.secondary)
                }

                NavigationLink(destination: AccountSettingsView()) {
                    HStack(spacing: 12) {
                        settingsIcon("person.text.rectangle", color: .blue)
                        Text(.editProfile)
                    }
                }

                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    HStack(spacing: 12) {
                        settingsIcon("arrow.backward.square", color: .red)
                        Text(.logOut)
                    }
                }
            } else {
                NavigationLink(destination: LoginView()) {
                    HStack(spacing: 12) {
                        settingsIcon("person.crop.circle", color: .accentColor)
                        Text(.logIn)
                    }
                }

                NavigationLink(destination: RegistrationView()) {
                    HStack(spacing: 12) {
                        settingsIcon("person.crop.circle.badge.plus", color: .accentColor)
                        Text(.register)
                    }
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
                HStack(spacing: 12) {
                    settingsIcon("moon.fill", color: .indigo)
                    Text(.darkMode)
                }
            }

            NavigationLink(destination: Text("SUBSCRIPTIONS")) {
                HStack(spacing: 12) {
                    settingsIcon("star.fill", color: .orange)
                    Text(.manageSubscription)
                }
            }
        }
    }

    private var informationSection: some View {
        Section(header: Text(.information)) {
            NavigationLink(destination: TermsOfServiceView()) {
                HStack(spacing: 12) {
                    settingsIcon("doc.text", color: .gray)
                    Text(.termsOfService)
                }
            }

            NavigationLink(destination: PrivacyPolicyView()) {
                HStack(spacing: 12) {
                    settingsIcon("lock.shield", color: .green)
                    Text(.privacyPolicy)
                }
            }

            NavigationLink(destination: AboutView()) {
                HStack(spacing: 12) {
                    settingsIcon("info.circle", color: .blue)
                    Text(.about)
                }
            }
        }
    }

    private func fetchHabits() -> [Habit] {
        (try? context.fetch(FetchDescriptor<Habit>())) ?? []
    }

    private func fetchUsers() -> [User] {
        (try? context.fetch(FetchDescriptor<User>())) ?? []
    }

    private func settingsIcon(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .medium))
            .frame(width: 28, height: 28)
            .foregroundStyle(.white)
            .background(color.gradient)
            .clipShape(.rect(cornerRadius: 7))
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
                        fetchHabits().forEach {
                            $0.isSyncable = false
                            $0.isPublic = false
                            $0.challenges = []
                        }
                        guard let currentUser = fetchUsers().first(where: { $0.id == userManager.profile.id }) else { return }
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

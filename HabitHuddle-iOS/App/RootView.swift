//
//  RootView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftUI
import SwiftData

struct RootView: View {

    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("selectedTab") var selectedTab = 0
    @AppStorage("isDarkMode") var isDarkMode = false

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var context

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var userManager: LocalUserManager

    @ObservedObject private var deepLinkState = DeepLinkState.shared

    @State private var showLoggedOut = false
    @State private var showEmailVerifiedAlert = false
    @State private var emailVerificationErrorMessage: String?

    @Query
    var habits: [Habit]

    @Query
    var users: [User]

    @Query
    var challenges: [Challenge]

    var body: some View {
        ZStack {
            if hasSeenOnboarding {
                TabView(selection: $selectedTab) {
                    Tab(String(localized: .habits), systemImage: "checklist", value: 0) {
                        HabitListView()
                    }
                    Tab(String(localized: .friends), systemImage: "person.2", value: 1) {
                        MyFriendsView()
                    }
                    Tab(String(localized: .challenges), systemImage: "flag.pattern.checkered.2.crossed", value: 2) {
                        ChallengesListView(userID: userManager.profile.id)
                    }
                    Tab(String(localized: .settings), systemImage: "gear", value: 3) {
                        SettingsView()
                    }
                }
                .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await SyncManager.shared.flushPendingCheckIns()
                    await SyncManager.shared.performFullSync(localHabits: habits, in: context)
                }
                WidgetUpdater.update(with: habits)
            }
        }
        .onChange(of: habits) { _, newHabits in
            WidgetUpdater.update(with: newHabits)
        }
        .modifier(RootViewAlertsModifier(
            showLoggedOut: $showLoggedOut,
            showEmailVerifiedAlert: $showEmailVerifiedAlert,
            emailVerificationErrorMessage: $emailVerificationErrorMessage,
            resetPasswordToken: Binding(
                get: { deepLinkState.resetPasswordToken },
                set: { deepLinkState.resetPasswordToken = $0 }
            )
        ))
        .onChange(of: deepLinkState.emailVerificationToken) { _, newToken in
            guard let newToken else { return }
            handleEmailVerification(token: newToken)
        }
        .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
        .onAppear {
            verifyToken()
            //print("TOKEN: \(TokenManager.token)")
        }
    }

    private func verifyToken() {
        guard let _ = TokenManager.token else { return }

        Task {
            do {
                let dto = try await NetworkManager.shared.request(
                    endpoint: .me(),
                    method: .get,
                    responseType: UserDTO.self
                )
                // Write the fresh server state back to the local profile so things like
                // `isEmailVerified` self-heal on every cold start instead of staying
                // stuck at whatever value we cached at sign-in time.
                userManager.apply(dto)
            } catch {
                handleTokenError(error)
            }
        }
    }

    private func handleEmailVerification(token: String) {
        // Clear the pending token so re-receiving the same URL (e.g. from a backgrounded
        // app re-foregrounding into the same link) doesn't re-fire the flow.
        deepLinkState.emailVerificationToken = nil

        Task {
            do {
                let status = try await NetworkManager.shared.requestStatusCode(
                    endpoint: .verifyEmail(token: token),
                    method: .get,
                    isLoggingIn: true
                )

                if status == .ok {
                    if TokenManager.token != nil {
                        _ = try? await userManager.refreshFromServer()
                    }
                    await MainActor.run {
                        HapticManager.trigger(.success)
                        showEmailVerifiedAlert = true
                    }
                    return
                }

                // The token may have already been consumed (e.g. tapped on another device,
                // or browser navigated before the app intercepted). In that case the server
                // already marked the user verified, so confirm via /me.
                if let _ = TokenManager.token, (try? await userManager.refreshFromServer())?.isEmailVerified == true {
                    await MainActor.run {
                        HapticManager.trigger(.success)
                        showEmailVerifiedAlert = true
                    }
                    return
                }

                await MainActor.run {
                    if status == .gone {
                        emailVerificationErrorMessage = String(localized: "This verification link has expired. Please request a new one from inside the app.")
                    } else {
                        emailVerificationErrorMessage = String(localized: "This verification link is no longer valid.")
                    }
                }
            } catch {
                await MainActor.run {
                    emailVerificationErrorMessage = String(localized: "Couldn't confirm your email. Please check your connection and try again.")
                }
            }
        }
    }

    private func handleTokenError(_ error: Error) {
        if let error = error as? HHError, error == .unauthorized {
            showLoggedOut = true

            habits.forEach {
                $0.isSyncable = false
                $0.isPublic = false
            }
            appState.logout(userManager: userManager)
        }
    }
}

private struct ResetPasswordRoute: Identifiable {
    let token: String
    var id: String { token }
}

private struct RootViewAlertsModifier: ViewModifier {
    @Binding var showLoggedOut: Bool
    @Binding var showEmailVerifiedAlert: Bool
    @Binding var emailVerificationErrorMessage: String?
    @Binding var resetPasswordToken: String?

    func body(content: Content) -> some View {
        content
            .alert(String(localized: .youveBeenLoggedOut), isPresented: $showLoggedOut) {} message: {
                Text(.thisCanHappenIfYourSessionExpiresLogBackInToContinueSyncingYourHabitsAndUsingAllSocialFeatures)
            }
            .sheet(item: Binding(
                get: { resetPasswordToken.map(ResetPasswordRoute.init) },
                set: { resetPasswordToken = $0?.token }
            )) { route in
                NavigationStack {
                    ResetPasswordView(token: route.token)
                }
            }
            .alert(String(localized: "Email confirmed!"), isPresented: $showEmailVerifiedAlert) {
                Button(String(localized: .gotIt), role: .cancel) {}
            } message: {
                Text(String(localized: "Your email address is now verified."))
            }
            .alert(String(localized: "Verification failed"), isPresented: Binding(
                get: { emailVerificationErrorMessage != nil },
                set: { if !$0 { emailVerificationErrorMessage = nil } }
            )) {
                Button(String(localized: .gotIt), role: .cancel) {}
            } message: {
                Text(emailVerificationErrorMessage ?? "")
            }
    }
}

#Preview {
    RootView()
}

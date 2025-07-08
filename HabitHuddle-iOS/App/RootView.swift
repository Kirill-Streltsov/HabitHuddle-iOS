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
    
    @State private var showLoggedOut = false
                
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
                    Tab("Habits", systemImage: "checklist", value: 0) {
                        HabitListView()
                    }
                    Tab("Friends", systemImage: "person.2", value: 1) {
                        MyFriendsView()
                    }
                    Tab("Challenges", systemImage: "flag.pattern.checkered.2.crossed", value: 2) {
                        ChallengesListView(userID: userManager.profile.id)
                    }
                    Tab("Settings", systemImage: "gear", value: 3) {
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
                    await SyncManager.shared.performFullSync(localHabits: habits, in: context)
                }
            }
        }
        .alert("You've been logged out", isPresented: $showLoggedOut) {} message: {
            Text("This can happen if your session expires. Log back in to continue syncing your habits and using all social features.")
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
                _ = try await NetworkManager.shared.request(
                    endpoint: .me(),
                    method: .get,
                    responseType: UserDTO.self
                )
            } catch {
                handleTokenError(error)
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

#Preview {
    RootView()
}

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
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var userManager: LocalUserManager
                
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
                        HomeView()
                    }
                    Tab("Friends", systemImage: "person.2", value: 1) {
                        MyFriendsView()
                    }
                    Tab("Challenges", systemImage: "flag.pattern.checkered.2.crossed", value: 2) {
                        ChallengesListView()
                    }
                    Tab("Settings", systemImage: "gear", value: 3) {
                        SettingsView()
                            .environmentObject(LoginViewModel(appState: appState, userManager: userManager))
                    }
                }
                .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
//        .onChange(of: scenePhase) { _, newPhase in
//            if newPhase == .active {
//                Task {
//                    await SyncManager.shared.performFullSync(localHabits: habits, in: context)
//                }
//            }
//        }
        .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
        .onAppear {
            print("TOKEN: \(TokenManager.token)")
        }
        .onAppear {
//            for habit in Habit.createTestHabitsWithCheckIns() {
//                context.insert(habit)
//            }
            //context.insert(Habit.demoHabitWith13Of14CheckIns())
            print("Habits:")
            for habit in habits {
                print(habit.name)
            }
            print("Users:")
            for user in users {
                print(user.name)
            }
            print("Challenges:")
            for challenge in challenges {
                print(challenge.habit?.name)
            }
        }
    }
}

#Preview {
    RootView()
}

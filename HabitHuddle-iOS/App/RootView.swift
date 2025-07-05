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
        .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
        .onAppear {
            setHabitsSyncSetting()
            print("TOKEN: \(TokenManager.token)")
        }
        .onAppear {
//            for habit in Habit.createTestHabitsWithCheckIns() {
//                context.insert(habit)
//            }
//            context.insert(Habit.demoHabitWith13Of14CheckIns())
//            context.insert(Habit.demoHabitWith25Of14CheckIns())
//            context.insert(Habit.demoHabitWithFullCheckIns())
//            context.insert(Habit.demoHabitWithFullCheckIns())
            print("Habit categories")
            for habit in habits {
                print(habit.category)
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
    
    private func setHabitsSyncSetting() {
        if TokenManager.token == nil {
            habits.forEach { $0.isSyncable = false }
        }
    }
}

#Preview {
    RootView()
}

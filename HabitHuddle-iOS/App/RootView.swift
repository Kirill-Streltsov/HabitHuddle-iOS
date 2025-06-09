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
    
    @Query
    var habits: [Habit]
    
    var body: some View {
        ZStack {
            if hasSeenOnboarding {
                TabView(selection: $selectedTab) {
                    Tab("Habits", systemImage: "checklist", value: 0) {
                        HomeView()
                    }
                    Tab("Statistics", systemImage: "chart.bar", value: 1) {
                        StatisticsListView()
                    }
                    Tab("Friends", systemImage: "person.2", value: 2) {
                        FriendsListView()
                    }
                    Tab("Challenges", systemImage: "trophy", value: 3) {
                        ChallengesListView()
                    }
                    Tab("Settings", systemImage: "gear", value: 4) {
                        SettingsView()
                    }
                }
                .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await SyncManager.shared.performFullSync(localHabits: habits, in: context)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
        .onAppear {
            print("TOKEN: \(TokenManager.token)")
        }
    }
}

#Preview {
    RootView()
}

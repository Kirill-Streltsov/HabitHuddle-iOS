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
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ZStack {
            if hasSeenOnboarding {
                TabView(selection: $selectedTab) {
                    Tab("Habits", systemImage: "checklist", value: 0) {
                        HomeView()
                    }
                    Tab("Friends", systemImage: "person.2", value: 1) {
                        FriendsListView()
                    }
                    Tab("Challenges", systemImage: "trophy", value: 2) {
                        ChallengesListView()
                    }
                    Tab("Statistics", systemImage: "chart.bar", value: 3) {
                        StatisticsListView()
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
        .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
        .onAppear {
            print("TOKEN: \(TokenManager.token)")
//            Task {
//                await SyncManager.shared.retry(from: context)
//            }
        }
    }
}

#Preview {
    RootView()
}

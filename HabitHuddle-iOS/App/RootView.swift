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
                        //SettingsView()
                        VStack {
                            ChallengeProgressCardView(
                                challenge: ChallengeDTO(
                                    id: UUID(),
                                    initiatorName: "Alice",
                                    receiverName: "You",
                                    habitName: "Read 20 pages a day",
                                    type: .competitive,
                                    status: .accepted,
                                    startDate: Date(),
                                    endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                                ),
                                initiatorProgress: 0.62,
                                receiverProgress: 0.83
                            )
                            ChallengeCardView(
                                challenge: ChallengeDTO(
                                    id: UUID(),
                                    initiatorName: "Jennifer",
                                    receiverName: "You",
                                    habitName: "Morning runs together",
                                    type: .supportive,
                                    status: .pending,
                                    startDate: Date(),
                                    endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                                ),
                                onAccept: {},
                                onReject: {}
                            )
                        }
                        
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
            print("🔁 Retrying syncing all data")
            Task {
                await SyncManager.shared.retry(from: context)
            }
        }
    }
}

#Preview {
    RootView()
}

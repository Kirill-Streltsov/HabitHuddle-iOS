//
//  RootView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            if hasSeenOnboarding {
                    TabView {
                        Tab("Habits", systemImage: "checklist") {
                            HomeView()
                        }
                        Tab("Statistics", systemImage: "chart.bar") {
                            StatisticsList()
                        }
                        Tab("Demo", systemImage: "checklist") {
                            ChallengeProgressCardView(
                                challenge: ChallengeDTO(
                                    id: UUID(),
                                    initiatorName: "Alice",
                                    receiverName: "You",
                                    habitName: "Daily Reading",
                                    type: .competitive,
                                    status: .accepted,
                                    startDate: Date(),
                                    endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                                ),
                                initiatorProgress: 0.67,
                                receiverProgress: 0.828
                            )
                        }
                    }
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
    }
}

#Preview {
    RootView()
}

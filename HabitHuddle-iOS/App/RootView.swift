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
                if appState.isAuthenticated {
                    TabView {
                        Tab("Habits", systemImage: "checklist") {
                            HomeView()
                        }
                        Tab("Statistics", systemImage: "chart.bar") {
                            StatisticsList()
                        }
                        Tab("Demo", systemImage: "checklist") {
                            ChallengeCardView(
                                challenge: ChallengeDTO(
                                    id: UUID(),
                                    initiatorName: "Alice",
                                    receiverName: "You",
                                    habitName: "No caffeine before sleep",
                                    type: .supportive,
                                    status: .pending,
                                    startDate: Date(),
                                    endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                                ),
                                onAccept: {},
                                onReject: {}
                            )
                            ChallengeCardView(
                                challenge: ChallengeDTO(
                                    id: UUID(),
                                    initiatorName: "James",
                                    receiverName: "You",
                                    habitName: "Read 20 pages a day",
                                    type: .competitive,
                                    status: .pending,
                                    startDate: Date(),
                                    endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
                                ),
                                onAccept: {},
                                onReject: {}
                            )
                            ChallengeCardView(
                                challenge: ChallengeDTO(
                                    id: UUID(),
                                    initiatorName: "Alice",
                                    receiverName: "You",
                                    habitName: "No caffeine before sleep",
                                    type: .supportive,
                                    status: .pending,
                                    startDate: Date(),
                                    endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                                ),
                                onAccept: {},
                                onReject: {}
                            )
                            ChallengeCardView(
                                challenge: ChallengeDTO(
                                    id: UUID(),
                                    initiatorName: "James",
                                    receiverName: "You",
                                    habitName: "Read 20 pages a day",
                                    type: .competitive,
                                    status: .pending,
                                    startDate: Date(),
                                    endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
                                ),
                                onAccept: {},
                                onReject: {}
                            )
                        }
                    }
                    .transition(.move(edge: .trailing))
                } else {
                    LoginView(appState: appState)
                        .transition(.opacity)
                }
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}

#Preview {
    RootView()
}

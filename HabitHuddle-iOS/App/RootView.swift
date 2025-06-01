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
                            EmptyStatisticsView()
                        }
                    }
                    .transition(.move(edge: .trailing))

                } else {
                    LoginView(appState: appState)
                        .transition(.move(edge: .leading))
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

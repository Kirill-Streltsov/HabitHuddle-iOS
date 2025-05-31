//
//  RootView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            if appState.isAuthenticated {
                TabView {
                    Tab("Habits", systemImage: "checklist") {
                        HomeView()
                    }
                    Tab("Statistics", systemImage: "chart.bar") {
                        StatisticsView(habit: Habit.createTestHabitWithCheckIns())
                    }
                    
                }
                .transition(.move(edge: .trailing))

            } else {
                LoginView(appState: appState)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}

#Preview {
    RootView()
}

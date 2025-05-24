//
//  RootView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            if appState.isAuthenticated {
                TabView {
                    Tab("Habits", systemImage: "brain.head.profile") {
                        HomeView()
                    }
                    Tab("Home", systemImage: "house") {
                        HomeView()
                    }
                    Tab("Home", systemImage: "house") {
                        HomeView()
                    }
                }
                .transition(.move(edge: .trailing))
                
            } else {
                LoginView(appState: appState, modelContext: modelContext)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}

#Preview {
    RootView()
}

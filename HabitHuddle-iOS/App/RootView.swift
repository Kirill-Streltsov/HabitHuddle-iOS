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
                HomeView()
                    .transition(.move(edge: .trailing))
            } else {
                let viewModel = LoginView.ViewModel(appState: appState, modelContext: modelContext)
                LoginView(viewModel: viewModel)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}

#Preview {
    RootView()
}

//
//  ChallengesList.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct ChallengesListView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if !appState.isAuthenticated {
                    EmptyFriendsView()
                }
            }
            .navigationTitle("Challenges")
        }
    }
}

#Preview {
    ChallengesListView()
}

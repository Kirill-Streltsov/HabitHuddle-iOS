//
//  ChallengesList.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct ChallengesList: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if !appState.isAuthenticated {
                    UnauthenticatedChallengesView()
                }
            }
            .navigationTitle("Challenges")
        }
    }
}

#Preview {
    ChallengesList()
}

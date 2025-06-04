//
//  ChallengesList.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct ChallengesListView: View {
    
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.challenges.isEmpty {
                    EmptyChallengesView()
                    VStack {
                        HStack {
                            Text("Choose a habit to challenge a friend!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            Spacer()
                        }
                    }
                } else {
                    ForEach(viewModel.challenges) { challenge in
                        ChallengeCardView(challenge: challenge) {
                            await viewModel.acceptChallenge(with: challenge.id)
                        } onReject: {
                            await viewModel.rejectChallenge(with: challenge.id)
                        }
                    }
                }
            }
            .task {
                await viewModel.getMyChallenges()
            }
            .navigationTitle("Challenges")
        }
    }
}

#Preview {
    ChallengesListView()
}

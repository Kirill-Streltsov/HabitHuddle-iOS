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
    @EnvironmentObject var userManager: LocalUserManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.challenges.isEmpty {
                    EmptyChallengesView()
                } else {
                    if !viewModel.challenges.filter({ $0.status == .pending }).isEmpty {
                        VStack {
                            Text("Pending Challenges")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(viewModel.challenges.filter { $0.status == .pending }) { challenge in
                                ChallengeCardView(challenge: challenge) {
                                    await viewModel.acceptChallenge(with: challenge.id)
                                } onReject: {
                                    await viewModel.rejectChallenge(with: challenge.id)
                                }
                            }
                        }
                    }
                    if !viewModel.challenges.filter({ $0.status == .accepted }).isEmpty {
                        VStack {
                            Text("Ongoing Challenges")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(viewModel.challenges.filter { $0.status == .accepted }) { challenge in
                                ChallengeProgressCardView(detailedChallenge: challenge)
                            }
                        }
                    }
                    if !viewModel.challenges.filter({ $0.status == .declined }).isEmpty {
                        VStack {
                            Text("Declined Challenges")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(viewModel.challenges.filter { $0.status == .declined }) { challenge in
                                ChallengeCardView(challenge: challenge) {
                                    await viewModel.acceptChallenge(with: challenge.id)
                                } onReject: {
                                    await viewModel.rejectChallenge(with: challenge.id)
                                }
                            }
                        }
                    }
                }
            }

            .task {
                await viewModel.getChallenges(for: userManager.profile.id)
            }
            .navigationTitle("Challenges")
        }
    }
}

#Preview {
    ChallengesListView()
}

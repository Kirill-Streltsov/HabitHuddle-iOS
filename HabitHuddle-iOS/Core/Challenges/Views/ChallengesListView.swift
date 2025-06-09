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
                            Text("Pending")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(viewModel.challenges.filter { $0.status == .pending }) { challenge in
                                ChallengeCardView(challenge: challenge) {
                                    
                                    let acceptedResult = await viewModel.acceptChallenge(with: challenge.id)
                                    Helpers.handleResult(acceptedResult) { result in
                                        if result == .ok {
                                            
                                        }
                                    }
                                } onReject: {
                                    await viewModel.rejectChallenge(with: challenge.id)
                                }
                            }
                        }
                    }
                    if !viewModel.challenges.filter({ $0.status == .accepted }).isEmpty {
                        VStack {
                            Text("Ongoing")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(viewModel.challenges.filter { $0.status == .accepted }) { challenge in
                                ChallengeProgressCardView(challenge: challenge)
                            }
                        }
                    }
                    if !viewModel.challenges.filter({ $0.status == .declined }).isEmpty {
                        VStack {
                            Text("Declined")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(viewModel.challenges.filter { $0.status == .declined }) { challenge in
                                ChallengeCardView(challenge: challenge) {
                                    let acceptedResult = await viewModel.acceptChallenge(with: challenge.id)
                                } onReject: {
                                    let rejectedResult = await viewModel.rejectChallenge(with: challenge.id)
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

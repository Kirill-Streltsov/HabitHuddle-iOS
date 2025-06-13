//
//  ChallengesList.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI
import SwiftData

struct ChallengesListView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    @Query
    var challenges: [Challenge]
    
    @Environment(\.modelContext) private var context
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
                                challengeCard(with: challenge)
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
                                challengeCard(with: challenge)
                            }
                        }
                    }
                }
            }
            .task {
                await viewModel.getChallenges(for: userManager.profile.id)
            }
            .navigationTitle("Challenges")
            .onAppear {
                for challenge in challenges {
                    print("CHALLENGE FOR HABIT: \(challenge.habit.name)")
                    print("CHALLENGE: \(challenge)")
                }
            }
        }
    }

    private func challengeCard(with challenge: ChallengeDTO) -> some View {
        ChallengeCardView(challenge: challenge) {
            let acceptedResult = await viewModel.acceptChallenge(with: challenge.id)
            Helpers.handleResult(acceptedResult) { status in
                if status == .ok {
                    saveChallengeLocally(from: challenge)
                } else {
                    print("STATUS IS NOT OK")
                }
            } onFailure: { error in
                print("Failed to accept the challenge: \(error.localizedDescription)")
            }
        } onReject: {
            let rejectedResult = await viewModel.rejectChallenge(with: challenge.id)
            Helpers.handleResult(rejectedResult) { status in
                print("Successfully rejected the challenge with id: \(challenge.id)")
            } onFailure: { error in
                print("Failed to reject the challenge: \(error.localizedDescription)")
            }
        }
    }

    private func saveChallengeLocally(from challenge: ChallengeDTO) {
        Task {
            let habitID = challenge.initiatorHabitID
            let result = await viewModel.getHabitFromChallenge(with: habitID)

            Helpers.handleResult(result) { habitDTO in
                let habit = habitDTO.toSwiftData()
                habit.id = UUID()
                context.insert(habit)

                do {
                    try context.save()
                    print("✅ Habit created from challenge successfully.")
                } catch {
                    print("❌ Failed to save habit: \(error)")
                }
            } onFailure: { error in
                print("Something went wrong fetching habit: \(error)")
            }
        }
    }
}

#Preview {
    ChallengesListView()
}

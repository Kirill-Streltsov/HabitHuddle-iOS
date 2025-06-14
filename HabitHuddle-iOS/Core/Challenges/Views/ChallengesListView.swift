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
                    getHabit(from: challenge)
                } else {
                    print("STATUS IS NOT OK: \(status)")
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
    
    private func getHabit(from challenge: ChallengeDTO) {
        Task {
            var existingHabitID = UUID()
            if let habitID = challenge.initiatorHabitID {
                existingHabitID = habitID
            } else if let habitID = challenge.receiverHabitID {
                existingHabitID = habitID
            }
            let receivedHabitResult = await viewModel.getHabitFromChallenge(with: existingHabitID)
            
            Helpers.handleResult(receivedHabitResult) { habitDTO in
                var habitToSend = habitDTO
                habitToSend.id = UUID()
                createHabitAfterAcceptingChallenge(habitDTO: habitToSend, challengeID: challenge.id)
            } onFailure: { error in
                print("Something went wrong fetching habit: \(error)")
            }
        }
    }
    
    private func createHabitAfterAcceptingChallenge(habitDTO: HabitDTO, challengeID: UUID) {
        Task {
            let sentHabitResult = await viewModel.createHabitAfterAcceptingChallenge(habitDTO: habitDTO, for: challengeID)
            Helpers.handleResult(sentHabitResult) { createdHabit in
                let habit = createdHabit.toSwiftData()
                context.insert(habit)
                do {
                    try context.save()
                    print("✅ Habit created from challenge successfully.")
                } catch {
                    print("Couldn't save habit locally: \(error)")
                }
            } onFailure: { error in
                print("Something went wrong creating habit: \(error)")
            }
        }
    }
}

#Preview {
    ChallengesListView()
}

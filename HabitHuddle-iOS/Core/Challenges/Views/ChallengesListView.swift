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
    
    @Query
    var habits: [Habit]
    
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
            .onChange(of: viewModel.challenges) { oldChallenges, newChallenges in
                if !newChallenges.isEmpty {
                    for newChallenge in newChallenges {
                        if !challenges.contains(where: { $0.id == newChallenge.id }) {
                            getHabit(from: newChallenge)
                        }
                    }
                }
            }
            .navigationTitle("Challenges")
        }
    }
    
    private func challengeCard(with challenge: ChallengeDTO) -> some View {
        ChallengeCardView(challenge: challenge) {
            let acceptedResult = await viewModel.acceptChallenge(with: challenge.id)
            Helpers.handleResult(acceptedResult) { status in
                if status == .ok {
                    getHabit(from: challenge)
                }
            } onFailure: { error in
                print("❌ Failed to accept the challenge: \(error.localizedDescription)")
            }
        } onReject: {
            let rejectedResult = await viewModel.rejectChallenge(with: challenge.id)
            Helpers.handleResult(rejectedResult) { status in
                print("Successfully rejected the challenge with id: \(challenge.id)")
            } onFailure: { error in
                print("❌ Failed to reject the challenge: \(error.localizedDescription)")
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
                createHabitAfterAcceptingChallenge(habitDTO: habitToSend, challengeDTO: challenge)
            } onFailure: { error in
                print("❌ Something went wrong fetching habit: \(error)")
            }
        }
    }
    
    private func createHabitAfterAcceptingChallenge(habitDTO: HabitDTO, challengeDTO: ChallengeDTO) {
        Task {
            let sentHabitResult = await viewModel.createHabitAfterAcceptingChallenge(habitDTO: habitDTO, for: challengeDTO.id)
            Helpers.handleResult(sentHabitResult) { createdHabit in
                if !habits.contains(where: { $0.id == createdHabit.id }) {
                    let habit = createdHabit.toSwiftData()
                    context.insert(habit)
                    do {
                        try context.save()
                        saveChallengeLocally(from: challengeDTO, for: habit)
                        print("✅ Habit created from challenge successfully.")
                    } catch {
                        print("❌ Couldn't save habit locally: \(error)")
                    }
                }
            } onFailure: { error in
                print("❌ Something went wrong creating habit: \(error)")
            }
        }
    }
    
    private func saveChallengeLocally(from challengeDTO: ChallengeDTO, for habit: Habit) {
        let challenge = Challenge(
            id: challengeDTO.id,
            initiator: challengeDTO.initiator.user.toSwiftData(),
            receiver: challengeDTO.receiver.user.toSwiftData(),
            habit: habit,
            type: challengeDTO.type,
            status: challengeDTO.status,
            startDate: challengeDTO.startDate,
            endDate: challengeDTO.endDate,
            createdAt: .now)
        do {
            context.insert(challenge)
            try context.save()
        } catch {
            print("❌ Couldn't save challenge locally: \(error)")
        }
    }
}

#Preview {
    ChallengesListView()
}

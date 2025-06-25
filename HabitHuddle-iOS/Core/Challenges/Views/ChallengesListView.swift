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
    
    @Query
    var users: [User]
    
    var pendingChallengesSent: [ChallengeDTO] {
        viewModel.challenges.filter({ $0.status == .pending && $0.receiver.user.id != userManager.profile.id })
    }
    
    var pendingChallengesReceived: [ChallengeDTO] {
        viewModel.challenges.filter({ $0.status == .pending && $0.receiver.user.id == userManager.profile.id })
    }
    
    var acceptedChallenges: [ChallengeDTO] {
        viewModel.challenges.filter({ $0.status == .accepted })
    }
    
    var declinedChallenges: [ChallengeDTO] {
        viewModel.challenges.filter({ $0.status == .declined })
    }
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userManager: LocalUserManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.challenges.isEmpty {
                    EmptyChallengesView()
                } else {
                    if !(pendingChallengesSent + pendingChallengesReceived).isEmpty {
                        VStack {
                            Text("Pending")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(pendingChallengesReceived) { challenge in
                                challengeCard(with: challenge)
                            }
                            ForEach(pendingChallengesSent) { challenge in
                                SentChallengeCardView(challenge: challenge) {
                                    let _ = await viewModel.cancelChallenge(with: challenge.id)
                                }
                            }
                        }
                    }
                    if !acceptedChallenges.isEmpty {
                        VStack {
                            Text("Ongoing")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(acceptedChallenges) { challenge in
                                ChallengeProgressCardView(challenge: challenge)
                            }
                        }
                    }
                    if !declinedChallenges.isEmpty {
                        VStack {
                            Text("Declined")
                                .font(.title2)
                                .fontWeight(.semibold)
                            ForEach(declinedChallenges) { challenge in
                                challengeCard(with: challenge)
                            }
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .task {
                await viewModel.getChallenges(for: userManager.profile.id)
            }
            .onChange(of: viewModel.challenges) { oldChallenges, newChallenges in
                if !newChallenges.isEmpty {
                    for newChallenge in newChallenges.filter({ $0.status == .accepted }) {
                        if !challenges.contains(where: { $0.id == newChallenge.id }) {
                            guard let initiatorHabitID = newChallenge.initiatorHabitID else { return }
                            guard let habit = habits.filter({ $0.id == initiatorHabitID }).first else { return }
                            saveChallengeLocally(from: newChallenge, for: habit)
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
                    Task {
                        await viewModel.getChallenges(for: userManager.profile.id)
                    }
                    getHabit(from: challenge)
                }
            } onFailure: { error in
                print("❌ Error: Failed to accept the challenge: \(error.localizedDescription)")
            }
        } onReject: {
            let rejectedResult = await viewModel.rejectChallenge(with: challenge.id)
            Helpers.handleResult(rejectedResult) { status in
                Task {
                    await viewModel.getChallenges(for: userManager.profile.id)
                }
                print("✅ Successfully rejected the challenge with id: \(challenge.id)")
            } onFailure: { error in
                print("❌ Error: Failed to reject the challenge: \(error.localizedDescription)")
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
                print("❌ Error: Something went wrong fetching habit: \(error)")
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
                        print("❌ Error: Couldn't save habit locally: \(error)")
                    }
                }
            } onFailure: { error in
                print("❌ Error: Something went wrong creating habit: \(error)")
            }
        }
    }
    
    private func saveChallengeLocally(from challengeDTO: ChallengeDTO, for habit: Habit) {
        guard let initiator = users.filter({ $0.id == challengeDTO.initiator.user.id }).first else { return }
        guard let receiver = users.filter({ $0.id == challengeDTO.receiver.user.id }).first else { return }
        let challenge = Challenge(
            id: challengeDTO.id,
            initiator: initiator,
            receiver: receiver,
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
            print("❌ Error: Couldn't save challenge locally: \(error)")
        }
    }
}

#Preview {
    ChallengesListView()
}

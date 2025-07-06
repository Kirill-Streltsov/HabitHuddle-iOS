//
//  ChallengesList.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI
import SwiftData

struct ChallengesListView: View {
    
    @StateObject private var viewModel: ViewModel
    
    @Query
    var challenges: [Challenge]
    
    @Query
    var habits: [Habit]
    
    @Query
    var users: [User]
    
    @State private var showToast = false
    @State private var message = ""
    @State private var showChallengeDetail = false
    @State private var ongoingChallengeID = UUID()
        
    @Environment(\.modelContext) private var context
    @EnvironmentObject var appState: AppState
    
    let userID: UUID
    
    init(userID: UUID) {
        self.userID = userID
        _viewModel = StateObject(wrappedValue: ViewModel(userID: userID))
    }
    
    var body: some View {
        NavigationStack {
                ScrollView {
                    if !appState.isAuthenticated {
                        UnauthenticatedView(description: "Log in to view and take part in challenges with friends.")
                    } else {
                        if viewModel.challenges.isEmpty {
                            EmptyContentView(
                                icon: "flag.slash",
                                title: "No Active Challenges Yet",
                                description: "Start a challenge with a friend to stay accountable and reach your goals together."
                            )
                        } else {
                            if !(viewModel.pendingChallengesSent + viewModel.pendingChallengesReceived).isEmpty {
                                pendingChallenges
                            }
                            if !viewModel.acceptedChallenges.isEmpty {
                                ongoingChallenges
                            }
                            if !viewModel.declinedChallenges.isEmpty {
                                declinedChallenges
                            }
                        }
                    }
                }
                .refreshable {
                    await viewModel.getChallenges(for: userID)
                    ongoingChallengeID = UUID()
                }
                .toast(
                    isPresented: $showToast,
                    message: message,
                    icon: "flag.pattern.checkered.2.crossed"
                )
                .background(Color(.systemGroupedBackground))
                .task {
                    await viewModel.getChallenges(for: userID)
                }
                .onChange(of: viewModel.challenges) { _, newChallenges in
                    if !newChallenges.isEmpty {
                        for newChallenge in viewModel.acceptedChallenges {
                            if !challenges.contains(where: { $0.id == newChallenge.id }) {
                                updateLocalStorage(from: newChallenge)
                            }
                        }
                    }
                }
                .navigationTitle("Challenges")
        }
    }
    
    private var pendingChallenges: some View {
        VStack {
            Text("Pending")
                .font(.title2)
                .fontWeight(.semibold)
            ForEach(viewModel.pendingChallengesReceived) { challenge in
                challengeCard(with: challenge)
            }
            ForEach(viewModel.pendingChallengesSent) { challenge in
                SentChallengeCardView(challenge: challenge) {
                    let result = await viewModel.cancelChallenge(with: challenge.id)
                    Helpers.handleResult(result) { status in
                        if status == .ok {
                            showToast = true
                            message = "Challenge withdrawn"
                            HapticManager.trigger(.success)
                            Task {
                                await viewModel.getChallenges(for: userID)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var ongoingChallenges: some View {
        VStack {
            Text("Ongoing")
                .font(.title2)
                .fontWeight(.semibold)
            ForEach(viewModel.acceptedChallenges) { challenge in
                ChallengeProgressCardView(challenge: challenge)
                    .id(ongoingChallengeID)
                    .onTapGesture {
                        HapticManager.trigger(.selection)
                        showChallengeDetail = true
                    }
                    .sheet(isPresented: $showChallengeDetail) {
                        ChallengeCheckInsListView(challenge: challenge)
                    }
            }
        }
    }
    
    private var declinedChallenges: some View {
        VStack {
            Text("Declined")
                .font(.title2)
                .fontWeight(.semibold)
            ForEach(viewModel.declinedChallenges) { challenge in
                challengeCard(with: challenge)
            }
        }
    }
    
    private func updateLocalStorage(from challenge: ChallengeDTO) {
        guard let habit = habits.filter({ $0.id == challenge.initiatorHabitID || $0.id == challenge.receiverHabitID }).first else {
            getHabit(from: challenge)
            return
        }
        saveChallengeLocally(from: challenge, for: habit)
    }
        
    private func challengeCard(with challenge: ChallengeDTO) -> some View {
        ChallengeCardView(challenge: challenge) {
            let acceptedResult = await viewModel.acceptChallenge(with: challenge.id)
            Helpers.handleResult(acceptedResult) { status in
                if status == .ok {
                    HapticManager.trigger(.success)
                    message = "Challenge accepted!"
                    showToast = true
                    Task {
                        await viewModel.getChallenges(for: userID)
                    }
                    updateLocalStorage(from: challenge)
                }
            } onFailure: { error in
                print("❌ Error: Failed to accept the challenge: \(error.localizedDescription)")
            }
        } onReject: {
            let rejectedResult = await viewModel.rejectChallenge(with: challenge.id)
            Helpers.handleResult(rejectedResult) { status in
                if status == .ok {
                    HapticManager.trigger(.success)
                    message = "Challenge rejected!"
                    showToast = true
                }
                Task {
                    await viewModel.getChallenges(for: userID)
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
                    let habit = createdHabit.saved(in: context)
                    habit.isPublic = true
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
        let challenge = challengeDTO.toSwiftData(initiator: initiator, receiver: receiver, habit: habit)
        do {
            context.insert(challenge)
            try context.save()
            print("✅ Saved challenge locally")
        } catch {
            print("❌ Error: Couldn't save challenge locally: \(error)")
        }
    }
    
    private func habitAlreadyExists(with receiverHabitID: UUID?, or initiatorHabitID: UUID?) -> Bool {
        if habits.filter({ $0.id == receiverHabitID }).first != nil && habits.filter({ $0.id == initiatorHabitID }).first != nil {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    ChallengesListView(userID: UUID())
}

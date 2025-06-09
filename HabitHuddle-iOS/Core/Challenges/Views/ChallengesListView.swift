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
                                ChallengeCardView(challenge: challenge) {
                                    
                                    let acceptedResult = await viewModel.acceptChallenge(with: challenge.id)
                                    Helpers.handleResult(acceptedResult) { result in
                                        
                                    } onFailure: { _ in
                                        
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
                                    Helpers.handleResult(acceptedResult) { status in
                                        if status == .ok {
                                            saveChallengeLocally(from: challenge)
                                        }
                                    } onFailure: { _ in
                                        
                                    }
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
    
    private func saveChallengeLocally(from challenge: ChallengeDTO) {
        do {
            let descriptorHabit = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == challenge.habitID })
            let habits = try context.fetch(descriptorHabit)
            guard let habit = habits.first else {
                print("ERROR: Couldn't load the habit from SwiftData with habitID: \(challenge.habitID)")
                return
            }
            
            let descriptorInitiator = FetchDescriptor<User>(predicate: #Predicate { $0.id == challenge.initiator.user.id })
            let initiators = try context.fetch(descriptorInitiator)
            guard let initiator = initiators.first else {
                print("ERROR: Couldn't load the habit from SwiftData with habitID: \(challenge.habitID)")
                return
            }
            
            let descriptorReceiver = FetchDescriptor<User>(predicate: #Predicate { $0.id == challenge.receiver.user.id })
            let receivers = try context.fetch(descriptorReceiver)
            guard let receiver = receivers.first else {
                print("ERROR: Couldn't load the habit from SwiftData with habitID: \(challenge.habitID)")
                return
            }
            
            let challengeToSave = Challenge(
                id: challenge.id,
                initiator: initiator,
                receiver: receiver,
                habit: habit,
                type: challenge.type,
                status: challenge.status,
                startDate: challenge.startDate,
                endDate: challenge.endDate,
                createdAt: .now)
            context.insert(challengeToSave)
            try? context.save()
        } catch {
            print("ERROR: Couldn't save the habit to SwiftData with habitID: \(challenge.habitID)")
        }
    }
}

#Preview {
    ChallengesListView()
}

//
//  FriendDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI
import SwiftData

struct FriendDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var userManager: LocalUserManager

    @StateObject private var viewModel = ViewModel()
    let friend: UserDTO

    @State private var showToast = false
    @State private var message = ""
    @State private var heatmapID = UUID()
    @State private var didShowBoostSent = false
    @State private var selectedChallenge: ChallengeDTO? = nil

    @Query
    var users: [User]

    var body: some View {
        ScrollView {
            VStack {
                CardView {
                    VStack {
                        Text(.sActivity(friend.name))
                            .font(.title2)
                            .fontWeight(.semibold)
                        HeatmapHabitDTOView(habits: viewModel.habits)
                            .id(heatmapID)
                    }
                }
                Divider()
                friendHabits
                Divider()
                friendChallenges
            }
            .padding(.bottom, 32)
            .task {
                await viewModel.getUserHabits(for: friend.id)
                await viewModel.getChallenges(currentUserID: userManager.profile.id, friendID: friend.id)
            }
        }
        .onChange(of: viewModel.habits.count) { _, newValue in
            if newValue > 0 {
                heatmapID = UUID()
            }
        }
        .toast(
            isPresented: $didShowBoostSent,
            message: String(localized: .boostNotificationSent),
            icon: "bell.fill"
        )
        .toast(isPresented: $showToast, message: message)
        .background(Color(.systemGroupedBackground))
        .sheet(item: $selectedChallenge) { challenge in
            ChallengeCheckInsListView(
                challenge: challenge,
                onCancel: challenge.status == .accepted ? { await cancelChallenge(challenge) } : nil
            )
        }
        .toolbar {
            Button {
                Task {
                    await viewModel.deleteFriend(with: friend.id)
                }
                deleteFriendLocally()
                dismiss()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle(friend.username)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var friendHabits: some View {
        Group {
            if !viewModel.habits.isEmpty {
                Text(.sHabits(friend.name))
                    .font(.title2)
                    .fontWeight(.semibold)
                VStack(alignment: .center) {
                    ForEach(viewModel.habits) { habitDTO in
                        FriendHabitCard(
                            habitDTO: habitDTO,
                            isBoosted: viewModel.isBoosted(habitDTO.id),
                            isChallengePending: habitDTO.challenges?.isEmpty == false,
                            onSendBoost: {
                                didShowBoostSent = true
                                await viewModel.sendBoost(to: friend.id, about: habitDTO.id)
                            },
                            onChallenge: { days in
                                let success = await viewModel.sendChallenge(to: friend.id, for: habitDTO.id, durationDays: days)
                                showToast = true
                                message = success
                                    ? String(localized: .challengeSent)
                                    : String(localized: .challengeAlreadySent)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            } else {
                EmptyFriendHabitsView(name: friend.name)
            }
        }
    }
    
    private var friendChallenges: some View {
        Group {
            if !viewModel.challenges.isEmpty {
                VStack(alignment: .center) {
                    Text(.sChallenges(friend.name))
                        .font(.title2)
                        .fontWeight(.semibold)
                    ForEach(viewModel.challenges) { challenge in
                        ChallengeProgressCardView(challenge: challenge)
                            .onTapGesture {
                                HapticManager.trigger(.selection)
                                selectedChallenge = challenge
                            }
                    }
                }
            }
        }
    }
    
    @MainActor
    private func cancelChallenge(_ challenge: ChallengeDTO) async {
        let result = await viewModel.cancelChallenge(with: challenge.id)
        switch result {
        case .success(let status) where status == .ok:
            deleteLocalChallenge(challenge.id)
            selectedChallenge = nil
            await viewModel.getChallenges(currentUserID: userManager.profile.id, friendID: friend.id)
            HapticManager.trigger(.success)
            message = String(localized: .challengeWithdrawn)
            showToast = true
        default:
            HapticManager.trigger(.error)
            message = String(localized: .somethingWentWrongPleaseTryAgain)
            showToast = true
        }
    }

    @MainActor
    private func deleteLocalChallenge(_ id: UUID) {
        guard let local = (try? context.fetch(FetchDescriptor<Challenge>()))?.first(where: { $0.id == id }) else { return }
        context.delete(local)
        context.saveOrLog()
    }

    private func deleteFriendLocally() {
        guard let friend = users.filter({ $0.id == friend.id }).first else { return }
        context.delete(friend)
        context.saveOrLog()
    }
}

#Preview {
    FriendDetailView(friend: UserDTO(id: UUID(), username: "username", name: "Jack", createdAt: .now, updatedAt: .now))
        .environmentObject(LocalUserManager())
}

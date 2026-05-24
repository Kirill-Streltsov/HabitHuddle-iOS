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

    @StateObject private var viewModel = ViewModel()
    let friend: UserDTO

    @State private var showToast = false
    @State private var message = ""
    @State private var heatmapID = UUID()
    @State private var didShowBoostSent = false

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
            .task {
                await viewModel.getUserHabits(for: friend.id)
                await viewModel.getUserChallenges(for: friend.id)
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
                            onChallenge: {
                                let success = await viewModel.sendChallenge(to: friend.id, for: habitDTO.id)
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
                    }
                }
            }
        }
    }
    
    private func deleteFriendLocally() {
        guard let friend = users.filter({ $0.id == friend.id }).first else { return }
        context.delete(friend)
        context.saveOrLog()
    }
}

#Preview {
    FriendDetailView(friend: UserDTO(id: UUID(), username: "username", name: "Jack", createdAt: .now, updatedAt: .now))
}

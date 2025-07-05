//
//  FriendDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct FriendDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = ViewModel()
    let friend: UserDTO
    
    @State private var showToast = false
    @State private var message = ""
    @State private var heatmapID = UUID()
    
    var body: some View {
        ScrollView {
            VStack {
                CardView {
                    VStack {
                        Text("\(friend.name)'s activity")
                            .font(.title2)
                            .fontWeight(.semibold)
                        HeatmapView(habits: viewModel.habits.map{ $0.toSwiftData() })
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
        .toast(isPresented: $showToast, message: message)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            Button {
                Task {
                    await viewModel.deleteFriend(with: friend.id)
                }
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
                Text("\(friend.name)'s habits")
                    .font(.title2)
                    .fontWeight(.semibold)
                VStack(alignment: .center) {
                    ForEach(viewModel.habits) { habitDTO in
                        FriendHabitCard(habitDTO: habitDTO) {
                            Task {
                                let result = await viewModel.sendChallenge(to: friend.id, for: habitDTO.id, ofType: .supportive)
                                Helpers.handleResult(result) { result in
                                    showToast = true
                                    message = "Supportive challenge sent!"
                                }
                            }
                        } onCompetitiveCalled: {
                            Task {
                                let result = await viewModel.sendChallenge(to: friend.id, for: habitDTO.id, ofType: .competitive)
                                Helpers.handleResult(result) { result in
                                    showToast = true
                                    message = "Competitive challenge sent!"
                                }
                            }
                        }
                    }
                }
            } else {
                EmptyFriendHabitsView(name: friend.name)
            }
        }
    }
    
    private var friendChallenges: some View {
        Group {
            if !viewModel.challenges.isEmpty {
                VStack(alignment: .center) {
                    Text("\(friend.name)'s challenges")
                        .font(.title2)
                        .fontWeight(.semibold)
                    ForEach(viewModel.challenges) { challenge in
                        ChallengeProgressCardView(challenge: challenge)
                    }
                }
            }
        }
    }
}

#Preview {
    FriendDetailView(friend: UserDTO(id: UUID(), username: "username", name: "Jack", createdAt: .now, updatedAt: .now))
}

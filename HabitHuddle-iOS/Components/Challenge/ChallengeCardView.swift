//
//  ChallengeCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: ChallengeDTO
    var isProcessing: Bool = false
    var onAccept: @MainActor () async -> Void
    var onReject: @MainActor () async -> Void

    @State private var isAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("\(challenge.habitName)")
                        .font(.headline)
                    
                    Text(.challengedYou(challenge.initiator.user.name))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Label("Challenge", systemImage: "flag.pattern.checkered.2.crossed")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack {
                Image(systemName: "calendar")
                Text(.dayChallenge(challenge.durationDays))
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            HStack {
                if isProcessing {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 8)
                    Spacer()
                } else {
                    Button {
                        Task {
                            await onReject()
                        }
                    } label: {
                        Text(.reject)
                            .fontWeight(.semibold)
                            .frame(minWidth: 80)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.9))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Spacer()
                    Button {
                        Task {
                            await onAccept()
                        }
                    } label: {
                        Text(.accept)
                            .fontWeight(.semibold)
                            .frame(minWidth: 80)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.9))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview("Pending received") {
    ChallengeCardView(
        challenge: ChallengeDTO(
            id: UUID(),
            initiatorHabitID: UUID(),
            receiverHabitID: UUID(),
            habitName: "Morning Run",
            startDate: .now,
            endDate: .now.addingTimeInterval(86_400 * 30),
            status: .pending,
            initiator: .init(
                user: .init(id: UUID(), username: "alex", name: "Alex", createdAt: .now, updatedAt: .now),
                progress: 0, checkInCount: 0, plannedDays: 30),
            receiver: .init(
                user: .init(id: UUID(), username: "you", name: "You", createdAt: .now, updatedAt: .now),
                progress: 0, checkInCount: 0, plannedDays: 30)
        ),
        onAccept: {},
        onReject: {}
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
}

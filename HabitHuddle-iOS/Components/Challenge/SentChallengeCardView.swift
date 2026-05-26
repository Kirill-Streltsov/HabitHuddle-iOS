//
//  SentChallengeCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 14.06.25.
//


import SwiftUI

struct SentChallengeCardView: View {
    @EnvironmentObject private var userManager: LocalUserManager
    let challenge: ChallengeDTO
    var onCancel: @MainActor () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.habitName)
                        .font(.headline)

                    Text(.youSentThisChallengeTo(challenge.receiver.user.name))
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

            // Duration
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text(.dayChallenge(challenge.durationDays))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(.waitingForToAccept(challenge.receiver.user.name))
                .font(.caption2)
                .foregroundStyle(.tertiary)

            // Cancel button
            Button {
                Task {
                    await onCancel()
                }
            } label: {
                Text(.cancelChallenge)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.9))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview("Pending sent") {
    SentChallengeCardView(
        challenge: ChallengeDTO(
            id: UUID(),
            initiatorHabitID: UUID(),
            receiverHabitID: UUID(),
            habitName: "Morning Run",
            startDate: .now,
            endDate: .now.addingTimeInterval(86_400 * 30),
            status: .pending,
            initiator: .init(
                user: .init(id: UUID(), username: "you", name: "You", createdAt: .now, updatedAt: .now),
                progress: 0, checkInCount: 0, plannedDays: 30),
            receiver: .init(
                user: .init(id: UUID(), username: "alex", name: "Alex", createdAt: .now, updatedAt: .now),
                progress: 0, checkInCount: 0, plannedDays: 30))
    ) {}
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
    .environmentObject(LocalUserManager())
}

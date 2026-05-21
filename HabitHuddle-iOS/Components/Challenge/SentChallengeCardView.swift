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

                Label(challenge.type.displayName, systemImage: challenge.type == .competitive ? "flame.fill" : "heart.fill")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background(challenge.type == .competitive ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .foregroundStyle(challenge.type == .competitive ? .red : .green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Dates
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text(.fromTo(formattedDate(challenge.startDate), formattedDate(challenge.endDate)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    SentChallengeCardView(
        challenge: ChallengeDTO(
            id: UUID(),
            initiatorHabitID: UUID(),
            receiverHabitID: UUID(),
            habitName: "",
            type: .competitive,
            startDate: .now,
            endDate: .now,
            status: .accepted,
            initiator: .init(
                user: .init(
                    id: UUID(),
                    username: "",
                    name: "",
                    createdAt: .now,
                    updatedAt: .now),
                progress: 0,
                checkInCount: 0,
                plannedDays: 0),
            receiver: .init(
                user: .init(
                    id: UUID(),
                    username: "",
                    name: "",
                    createdAt: .now,
                    updatedAt: .now),
                progress: 0,
                checkInCount: 0,
                plannedDays: 0))
    ) {}
}

//
//  PastChallengeCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.26.
//

import SwiftUI

struct PastChallengeCardView: View {

    @EnvironmentObject private var userManager: LocalUserManager
    let challenge: ChallengeDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.habitName)
                        .font(.headline)
                    Text(participantsText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    outcomeTag
                    if challenge.status == .completed {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text(.fromTo(formattedDate(challenge.startDate), formattedDate(challenge.endDate)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if challenge.status == .completed {
                VStack(alignment: .leading) {
                    ProgressRow(name: meRow.name, calculatedProgress: meRow.progress, color: .green)
                    ProgressRow(name: themRow.name, calculatedProgress: themRow.progress, color: .pink)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .padding(.horizontal)
    }

    private var meRow: (name: String, progress: Double) {
        if userManager.profile.id == challenge.initiator.user.id {
            return (challenge.initiator.user.username, challenge.initiator.clampedProgress)
        }
        return (challenge.receiver.user.username, challenge.receiver.clampedProgress)
    }

    private var themRow: (name: String, progress: Double) {
        if userManager.profile.id == challenge.initiator.user.id {
            return (challenge.receiver.user.username, challenge.receiver.clampedProgress)
        }
        return (challenge.initiator.user.username, challenge.initiator.clampedProgress)
    }

    private var participantsText: String {
        let i = challenge.initiator.user.name
        let r = challenge.receiver.user.name
        if userManager.profile.id == challenge.initiator.user.id {
            return String(localized: .youVs(i, r))
        } else {
            return String(localized: .vsYou(i, r))
        }
    }

    @ViewBuilder
    private var outcomeTag: some View {
        switch challenge.status {
        case .completed:
            switch challenge.outcome(for: userManager.profile.id) {
            case .youWon:
                tag(text: String(localized: .youWon), icon: "trophy.fill", color: .yellow)
            case .youLost:
                tag(text: String(localized: .youLost), icon: "flag", color: .gray)
            case .youAhead:
                tag(text: String(localized: .ahead), icon: "arrow.up.right", color: .green)
            case .youBehind:
                tag(text: String(localized: .behind), icon: "arrow.down.right", color: .gray)
            case .tied:
                tag(text: String(localized: .tied), icon: "equal", color: .blue)
            }
        case .declined:
            tag(text: String(localized: .declined), icon: "xmark", color: .red)
        default:
            EmptyView()
        }
    }

    private func tag(text: String, icon: String, color: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.footnote)
            .fontWeight(.semibold)
            .padding(8)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

private enum PastChallengePreviewFactory {
    @MainActor
    static func challenge(
        status: ChallengeStatus,
        myProgress: Double,
        theirProgress: Double
    ) -> ChallengeDTO {
        let myID = LocalUserManager().profile.id
        let theirID = UUID()
        let plannedDays = 30
        let now = Date()
        return ChallengeDTO(
            id: UUID(),
            initiatorHabitID: UUID(),
            receiverHabitID: UUID(),
            habitName: "Morning Run",
            startDate: now.addingTimeInterval(-86_400 * Double(plannedDays)),
            endDate: now.addingTimeInterval(-86_400),
            status: status,
            initiator: .init(
                user: .init(id: myID, username: "you", name: "You", createdAt: now, updatedAt: now),
                progress: myProgress,
                checkInCount: Int(myProgress * Double(plannedDays)),
                plannedDays: plannedDays
            ),
            receiver: .init(
                user: .init(id: theirID, username: "alex", name: "Alex", createdAt: now, updatedAt: now),
                progress: theirProgress,
                checkInCount: Int(theirProgress * Double(plannedDays)),
                plannedDays: plannedDays
            )
        )
    }
}

#Preview("You won") {
    PastChallengeCardView(
        challenge: PastChallengePreviewFactory.challenge(status: .completed, myProgress: 1.0, theirProgress: 0.7)
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
    .environmentObject(LocalUserManager())
}

#Preview("You lost") {
    PastChallengeCardView(
        challenge: PastChallengePreviewFactory.challenge(status: .completed, myProgress: 0.5, theirProgress: 1.0)
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
    .environmentObject(LocalUserManager())
}

#Preview("Ahead") {
    PastChallengeCardView(
        challenge: PastChallengePreviewFactory.challenge(status: .completed, myProgress: 0.7, theirProgress: 0.4)
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
    .environmentObject(LocalUserManager())
}

#Preview("Behind") {
    PastChallengeCardView(
        challenge: PastChallengePreviewFactory.challenge(status: .completed, myProgress: 0.3, theirProgress: 0.8)
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
    .environmentObject(LocalUserManager())
}

#Preview("Tied (both 100%)") {
    PastChallengeCardView(
        challenge: PastChallengePreviewFactory.challenge(status: .completed, myProgress: 1.0, theirProgress: 1.0)
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
    .environmentObject(LocalUserManager())
}

#Preview("Declined") {
    PastChallengeCardView(
        challenge: PastChallengePreviewFactory.challenge(status: .declined, myProgress: 0, theirProgress: 0)
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
    .environmentObject(LocalUserManager())
}

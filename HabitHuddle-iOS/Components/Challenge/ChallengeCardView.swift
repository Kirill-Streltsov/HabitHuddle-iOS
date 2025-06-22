//
//  ChallengeCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: ChallengeDTO
    var onAccept: @MainActor () async -> Void
    var onReject: @MainActor () async -> Void

    @State private var isAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("\(challenge.habitName)")
                        .font(.headline)
                    
                    (Text(challenge.initiator.user.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        + Text(" challenged you!"))
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Label(challenge.type.rawValue.capitalized, systemImage: challenge.type == .competitive ? "flame.fill" : "heart.fill")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background(challenge.type == .competitive ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .foregroundStyle(challenge.type == .competitive ? .red : .green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack {
                Image(systemName: "calendar")
                Text("From \(formattedDate(challenge.startDate)) to \(formattedDate(challenge.endDate))")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        
            HStack {
                Button {
                    Task {
                        await onReject()
                    }
                } label: {
                    Text("Reject")
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
                    Text("Accept")
                        .fontWeight(.semibold)
                        .frame(minWidth: 80)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.9))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ChallengeCardView(
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
                plannedDays: 0)),
        onAccept: {},
        onReject: {}
    )
}

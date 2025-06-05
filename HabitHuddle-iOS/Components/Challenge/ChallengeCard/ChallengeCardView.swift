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
    
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    (Text(viewModel.initiatorName)
                        .font(.headline)
                        .fontWeight(.bold)
                        + Text(" challenged you!"))
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("\(challenge.habit.name)")
                        .font(.subheadline)
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
        .task {
            await viewModel.getInitator(with: challenge.initiator.id)
        }
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
            initiator: .init(id: UUID()),
            receiver: .init(id: UUID()),
            habit: HabitDTO(
                id: UUID(),
                user: .init(id: UUID()),
                name: "Drink water",
                description: "Gotta stay hydrated",
                duration: .oneWeek,
                reminderTime: .now,
                createdAt: .now,
                updatedAt: .now,
                checkIns: []
            ),
            type: .competitive,
            status: .pending,
            startDate: .now,
            endDate: .now,
            createdAt: .now
        ),
        onAccept: {},
        onReject: {}
    )
}

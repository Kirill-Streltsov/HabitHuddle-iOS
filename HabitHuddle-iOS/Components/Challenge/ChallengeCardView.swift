//
//  ChallengeCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: ChallengeDTO
    var onAccept: () -> Void
    var onReject: () -> Void

    @State private var isAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    (Text(challenge.initiatorName)
                        .font(.headline)
                        .fontWeight(.bold)
                        + Text(" challenged you!"))
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("\(challenge.habitName)")
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
                Button(action: onReject) {
                    Text("Reject")
                        .fontWeight(.semibold)
                        .frame(minWidth: 80)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.9))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Spacer()
                Button(action: onAccept) {
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

struct ChallengeDTO: Identifiable {
    var id: UUID
    var initiatorName: String
    var receiverName: String
    var habitName: String
    var type: ChallengeType
    var status: ChallengeStatus
    var startDate: Date
    var endDate: Date
}

enum ChallengeType: String, Codable {
    case competitive
    case supportive
}

enum ChallengeStatus: String, Codable {
    case pending
    case accepted
    case declined
}

#Preview {
    ChallengeCardView(
        challenge: ChallengeDTO(
            id: UUID(),
            initiatorName: "Alice",
            receiverName: "You",
            habitName: "Morning Run",
            type: .competitive,
            status: .pending,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        ),
        onAccept: { print("Accepted") },
        onReject: { print("Rejected") }
    )
    .padding()
}

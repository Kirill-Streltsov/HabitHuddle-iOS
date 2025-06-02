//
//  ChallengeProgressCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct ChallengeProgressCardView: View {
    let challenge: ChallengeDTO
    let initiatorProgress: Double  // value from 0 to 1
    let receiverProgress: Double   // value from 0 to 1

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.habitName)
                        .font(.headline)
                    Text("\(challenge.initiatorName) vs \(challenge.receiverName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Label(challenge.type.rawValue.capitalized, systemImage: challenge.type == .competitive ? "flame.fill" : "heart.fill")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background(challenge.type == .competitive ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .foregroundColor(challenge.type == .competitive ? .red : .green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Dates
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text("From \(formattedDate(challenge.startDate)) to \(formattedDate(challenge.endDate))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Progress bars
            VStack(alignment: .leading) {
                ProgressRow(name: challenge.receiverName, progress: receiverProgress, color: .green)
                ProgressRow(name: challenge.initiatorName, progress: initiatorProgress, color: .pink)
            }

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

struct ProgressRow: View {
    let name: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .frame(height: 8)
                        .foregroundColor(Color.gray.opacity(0.2))
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: CGFloat(progress) * geo.size.width, height: 8)
                        .foregroundColor(color)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    ChallengeProgressCardView(
        challenge: ChallengeDTO(
            id: UUID(),
            initiatorName: "Alice",
            receiverName: "You",
            habitName: "Daily Reading",
            type: .competitive,
            status: .accepted,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        ),
        initiatorProgress: 0.6,
        receiverProgress: 0.8
    )
}

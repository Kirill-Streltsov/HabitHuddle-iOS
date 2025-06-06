//
//  ChallengeProgressCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct ChallengeProgressCardView: View {
    
    @EnvironmentObject private var userManager: LocalUserManager
    let challenge: ChallengeDTO
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.habitName)
                        .font(.headline)
                    Text(challengeTitleText())
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
            
            // Dates
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text("From \(formattedDate(challenge.startDate)) to \(formattedDate(challenge.endDate))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Progress bars
            VStack(alignment: .leading) {
                ProgressRow(name: challenge.receiver.user.username, calculatedProgress: challenge.receiver.progress, color: .green)
                ProgressRow(name: challenge.initiator.user.username, calculatedProgress: challenge.initiator.progress, color: .pink)
            }
            
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private func challengeTitleText() -> String {
        switch challenge.type {
        case .competitive:
            if userManager.profile.id == challenge.initiator.user.id {
                return "\(challenge.initiator.user.name) (You) vs \(challenge.receiver.user.name)"
            } else {
                return "\(challenge.initiator.user.name) vs \(challenge.receiver.user.name) (You)"
            }
        case .supportive:
            if userManager.profile.id == challenge.initiator.user.id {
                return "\(challenge.initiator.user.name) (You) with \(challenge.receiver.user.name)"
            } else {
                return "\(challenge.initiator.user.name) with \(challenge.receiver.user.name) (You)"
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ProgressRow: View {
    let name: String
    let calculatedProgress: Double
    let color: Color
    @State private var progress: Double = 0.0
    
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
            
            ProgressView(value: progress)
                .tint(color)
                .progressViewStyle(LinearProgressViewStyle())
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.4)) {
                            progress = calculatedProgress
                        }
                    }
                }
        }
    }
}

#Preview {
    ChallengeProgressCardView(
        challenge: ChallengeDTO(
            id: UUID(),
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
    )
}

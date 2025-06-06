//
//  ChallengeProgressCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct ChallengeProgressCardView: View {
    
    @EnvironmentObject private var userManager: LocalUserManager
    let detailedChallenge: ChallengeCardResponseDTO
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(detailedChallenge.habitName)
                        .font(.headline)
                    Text("\(detailedChallenge.initiator.user.name) vs \(detailedChallenge.receiver.user.name)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Label(detailedChallenge.type.rawValue.capitalized, systemImage: detailedChallenge.type == .competitive ? "flame.fill" : "heart.fill")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background(detailedChallenge.type == .competitive ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .foregroundStyle(detailedChallenge.type == .competitive ? .red : .green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Dates
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text("From \(formattedDate(detailedChallenge.startDate)) to \(formattedDate(detailedChallenge.endDate))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Progress bars
            VStack(alignment: .leading) {
                ProgressRow(name: detailedChallenge.receiver.user.name, calculatedProgress: detailedChallenge.receiver.progress, color: .green)
                ProgressRow(name: detailedChallenge.initiator.user.name, calculatedProgress: detailedChallenge.initiator.progress, color: .pink)
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
        detailedChallenge: ChallengeCardResponseDTO(
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

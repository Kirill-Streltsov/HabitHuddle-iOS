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
    let initiatorProgress: Double  // value from 0 to 1
    let receiverProgress: Double   // value from 0 to 1
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.habit.name)
                        .font(.headline)
                    Text("\(viewModel.initiator.name.isEmpty ? "Jennifer" : "") vs \(viewModel.receiver.name.isEmpty ? "You" : "")")
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
                ProgressRow(name: viewModel.receiver.name.isEmpty ? "Andrew (You)" : "", calculatedProgress: receiverProgress, color: .green)
                ProgressRow(name: viewModel.initiator.name.isEmpty ? "Jennifer" : "", calculatedProgress: initiatorProgress, color: .pink)
            }
            
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .padding(.horizontal)
        .task {
            await viewModel.getInitator(with: challenge.initiator.id)
            await viewModel.getReceiver(with: challenge.receiver.id)
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
            initiator: LightweightUser(id: UUID()),
            receiver: LightweightUser(id: UUID()),
            habit: HabitDTO(id: UUID(), user: .init(id: UUID()), name: "Drink water", description: "Gotta hydrate", duration: .oneWeek, reminderTime: .now, createdAt: .now, updatedAt: .now, checkIns: []),
            type: .competitive,
            status: .accepted,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            createdAt: .now
        ),
        initiatorProgress: 0.6,
        receiverProgress: 0.8
    )
}

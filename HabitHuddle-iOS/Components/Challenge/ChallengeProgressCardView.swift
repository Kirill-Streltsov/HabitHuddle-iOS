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
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.habitName)
                        .font(.headline)
                    Text(challengeTitleText())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()

                HStack(spacing: 6) {
                    outcomeTag

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Dates
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text(.fromTo(formattedDate(challenge.startDate), formattedDate(challenge.endDate)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Progress bars — current user on top in green, opponent below in pink
            VStack(alignment: .leading) {
                ProgressRow(name: meRow.name, calculatedProgress: meRow.progress, color: .green)
                ProgressRow(name: themRow.name, calculatedProgress: themRow.progress, color: .pink)
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

    private func challengeTitleText() -> String {
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
        switch challenge.outcome(for: userManager.profile.id) {
        case .youAhead:
            tag(text: String(localized: .ahead), icon: "arrow.up.right", color: .green)
        case .youBehind:
            tag(text: String(localized: .behind), icon: "arrow.down.right", color: .gray)
        case .tied:
            tag(text: String(localized: .tied), icon: "equal", color: .blue)
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
                .onChange(of: calculatedProgress) { _, newValue in
                    withAnimation(.easeOut(duration: 0.4)) {
                        progress = newValue
                    }
                }
        }
    }
}

#Preview {
    ChallengeProgressCardView(
        challenge: ChallengeDTO(
            id: UUID(),
            initiatorHabitID: UUID(),
            receiverHabitID: UUID(),
            habitName: "",
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

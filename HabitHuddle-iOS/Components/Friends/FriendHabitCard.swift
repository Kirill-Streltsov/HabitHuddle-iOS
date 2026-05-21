//
//  FriendHabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//


import SwiftUI
import SwiftData

struct FriendHabitCard: View {
    
    @State private var scale: Double = 1
    @State private var didSendBoost = false
    @Binding var showBoostSent: Bool
    var onSendBoost: @MainActor () async -> Void
    
    @Environment(\.modelContext) private var context
    
    let habitDTO: HabitDTO
    
    init(didShowBoostSent: Binding<Bool>, habitDTO: HabitDTO, onSendBoost: @escaping () async -> Void) {
        self._showBoostSent = didShowBoostSent
        self.habitDTO = habitDTO
        self.onSendBoost = onSendBoost
    }
    
    @State private var showActionSheet = false
    @State private var selectedOption = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                if let icon = habitDTO.icon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .padding(4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                VStack(alignment: .leading) {
                    HStack(spacing: 8) {
                        Text(habitDTO.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                    }
                    if !habitDTO.description.isEmpty {
                        Text(habitDTO.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            ZStack {
                VStack {
                    if habitDTO.isCheckedInToday {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 85))
                    } else {
                        CheckedInStateView(
                            isOn: didSendBoost,
                            fontSize: 80,
                            shouldFlicker: true,
                            iconOn: "bolt.circle.fill",
                            iconOff: "bolt.circle",
                            color: .orange
                        )
                        .scaleEffect(scale)
                        .allowsHitTesting(!didSendBoost)
                        .onTapGesture {
                            HapticManager.trigger(.success)
                            showBoostSent = true
                            didSendBoost = true
                            Task {
                                await onSendBoost()
                            }
                            scale += 0.15
                            Task { scale -= 0.15 }
                        }
                        .animation(.easeInOut(duration: 0.3), value: scale)
                    }
                    
                    Text(.tapToBoost)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .opacity(didSendBoost || habitDTO.isCheckedInToday ? 0 : 1)
                }
                .offset(y: -5)
                HStack {
                    StatItem(title: .longestStreak, value: .days(habitDTO.longestStreak))
                    Spacer()
                    StatItem(title: .done, value: "\(habitDTO.completionPercentage)%")
                }
            }
            .offset(y: 15)
            .frame(maxWidth: .infinity)
            
            HStack {
                if habitDTO.isCompleted {
                    Text(.habitFinished)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                } else {
                    if let checkIns = habitDTO.checkIns {
                        (Text(verbatim: "\(checkIns.count) / ") + Text(.days(habitDTO.duration.numberOfDays)))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding(.bottom, 4)
            
            HabitDTOProgressView(habit: habitDTO, height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FriendHabitCard(didShowBoostSent: .constant(true), habitDTO: HabitDTO(id: UUID(), user: LightweightUser(id: UUID()), name: "Drink water", description: "Drink 2 liters a day", category: "", duration: .oneWeek, reminderTime: .now, createdAt: .now, updatedAt: .now, checkIns: [], challenges: [], icon: "brain"), onSendBoost: {})
}

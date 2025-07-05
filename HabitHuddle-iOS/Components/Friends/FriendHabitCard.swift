//
//  FriendHabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//


import SwiftUI

struct FriendHabitCard: View {
    
    @State private var scale: Double = 1
    @State private var didSendBoost = false
    @Binding var showBoostSent: Bool
    var onSendBoost: @MainActor () async -> Void
    
    let habitDTO: HabitDTO
    let cardWidth: CGFloat = UIScreen.main.bounds.width - 60
    private var habit: Habit
    
    init(didShowBoostSent: Binding<Bool>, habitDTO: HabitDTO, onSendBoost: @escaping () async -> Void) {
        self._showBoostSent = didShowBoostSent
        self.habitDTO = habitDTO
        self.habit = habitDTO.toSwiftData()
        self.onSendBoost = onSendBoost
    }
    
    @State private var showActionSheet = false
    @State private var selectedOption = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                if let icon = habit.icon {
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
                        Text(habit.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                    }
                    if !habit.habitDescription.isEmpty {
                        Text(habit.habitDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
            .frame(width: cardWidth)
            
            ZStack {
                VStack {
                    if habit.isCheckedInToday {
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
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                scale -= 0.15
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: scale)
                    }
                    
                    Text("Tap to boost!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .opacity(didSendBoost ? 0 : 1)
                }
                .offset(y: -5)
                HStack {
                    StatItem(title: "Longest Streak", value: "\(habit.longestStreak) days")
                    Spacer()
                    StatItem(title: "Done", value: "\(habit.completionPercentage)%")
                }
            }
            .offset(y: 15)
            .frame(width: cardWidth)
            
            HStack {
                if habit.isCompleted {
                    Text("🎉 Habit finished!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                } else {
                    Text("\(habit.checkIns.count) / \(habit.duration.numberOfDays) days")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.bottom, 4)
            
            HabitProgressView(
                habit: habit,
                width: cardWidth,
                height: 8
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .frame(maxWidth: cardWidth)
    }
}

#Preview {
    FriendHabitCard(didShowBoostSent: .constant(true), habitDTO: HabitDTO(id: UUID(), user: LightweightUser(id: UUID()), name: "Drink water", description: "Drink 2 liters a day", category: "", duration: .oneWeek, reminderTime: .now, createdAt: .now, updatedAt: .now, checkIns: [], challenges: [], icon: "brain"), onSendBoost: {})
}

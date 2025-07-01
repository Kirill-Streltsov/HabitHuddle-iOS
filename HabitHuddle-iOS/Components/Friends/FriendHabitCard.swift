//
//  FriendHabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//


import SwiftUI

struct FriendHabitCard: View {
    let habitDTO: HabitDTO
    let cardWidth: CGFloat = UIScreen.main.bounds.width - 60
    private var habit: Habit
    var onSupportiveCalled: @MainActor () async -> Void
    var onCompetitiveCalled: @MainActor () async -> Void
    
    
    init(habitDTO: HabitDTO, onSupportiveCalled: @escaping @MainActor () async -> Void, onCompetitiveCalled: @escaping @MainActor () async -> Void) {
        self.habitDTO = habitDTO
        self.habit = habitDTO.toSwiftData()
        self.onSupportiveCalled = onSupportiveCalled
        self.onCompetitiveCalled = onCompetitiveCalled
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
                Image(systemName: habit.reminderTime != nil ? "bell.fill" : "bell.slash.fill")
                    .foregroundStyle(habit.reminderTime != nil ? .orange : .gray)
                
            }
            .frame(width: cardWidth)
            
            ZStack {
                CheckedInStateView(isCheckedIn: habit.isCheckedInToday, fontSize: 85, shouldFlicker: false)
                    .offset(y: -5)
                HStack {
                    StatItem(title: "Longest Streak", value: "\(habit.longestStreak) days")
                    Spacer()
                    StatItem(title: "Completion", value: "\(habit.completionPercentage)%")
                }
            }
            .offset(y: 15)
            .frame(width: cardWidth)
            
            HStack(alignment: .bottom) {
                
                Text("\(habit.checkIns.count) / \(habit.duration.numberOfDays) days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if habit.challenges.isEmpty {
                    Button {
                        showActionSheet = true
                    } label: {
                        Image(systemName: "flag.pattern.checkered.2.crossed")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .confirmationDialog("Choose the challenge type", isPresented: $showActionSheet, titleVisibility: .visible) {
                        Button("Supportive") {
                            Task {
                                await onSupportiveCalled()
                            }
                        }
                        Button("Competitive", role: .destructive) {
                            Task {
                                await onCompetitiveCalled()
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                } else if habit.challenges[0].type == .competitive {
                    Image(systemName: "flag.pattern.checkered.2.crossed")
                        .foregroundStyle(.pink)
                } else if habit.challenges[0].type == .supportive {
                    Image(systemName: "flag.pattern.checkered.2.crossed")
                        .foregroundStyle(.green)
                }
                
            }
            .padding(.bottom, 4)
            .frame(width: cardWidth)
            
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
    FriendHabitCard(habitDTO: HabitDTO(id: UUID(), user: LightweightUser(id: UUID()), name: "Drink water", description: "Drink 2 liters a day", category: "", duration: .oneWeek, reminderTime: .now, createdAt: .now, updatedAt: .now, checkIns: [], challenges: [], icon: "brain"), onSupportiveCalled: {}, onCompetitiveCalled: {})
}

//
//  HabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI
import SwiftData

struct HabitCard: View {
    
    @Environment(\.modelContext) private var context
    @State private var scale = 1.0
    @State private var challengeButtonPressed = false
        
    let habit: Habit
    let cardWidth: CGFloat = UIScreen.main.bounds.width - 60
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                    if !habit.habitDescription.isEmpty {
                        Text(habit.habitDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                Image(systemName: habit.reminderTime != nil ? "bell.fill" : "bell.slash.fill")
                    .foregroundStyle(habit.reminderTime != nil ? .orange : .gray)
                
            }
            .frame(width: cardWidth)
            
            ZStack {
                CheckedInStateView(isCheckedIn: habit.isCheckedInToday, fontSize: 85)
                    .onTapGesture {
                        HapticManager.trigger(.success)
                        habit.toggleCheckIn(in: context)
                        scale += 0.1
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            scale -= 0.1
                        }
                    }
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
                        challengeButtonPressed = true
                    } label: {
                        Image(systemName: "flag.pattern.checkered.2.crossed")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
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
        .frame(maxHeight: 225)
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 0.2), value: scale)
        .sheet(isPresented: $challengeButtonPressed) {
            MyFriendsListView(isInFriendsTab: false, habit: habit)
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    let habit = Habit(id: UUID(), user: LightweightUser(id: UUID()), name: "Demo Habit", description: "This is some description", duration: .oneWeek)
    VStack {
        HStack(spacing: 16) {
            HabitCard(habit: habit)
        }
    }
}

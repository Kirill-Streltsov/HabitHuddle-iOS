//
//  HabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI

struct HabitCard: View {
    @Environment(\.modelContext) private var context
    @State private var scale = 1.0
    let habit: Habit
    let cardWidth: CGFloat = UIScreen.main.bounds.width / 2 - 48

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(habit.name)
                    .font(.system(size: 20, weight: .semibold))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                
                VStack(spacing: 4) {
                    if let challenges = habit.challenges, !challenges.isEmpty {
                        Image(systemName: "flag.pattern.checkered.2.crossed")
                            .foregroundStyle(challenges[0].type == .competitive ? .pink : .green)
                    }
                    Image(systemName: habit.reminderTime != nil ? "bell.fill" : "bell.slash.fill")
                        .foregroundStyle(habit.reminderTime != nil ? .orange : .gray)
                }
            }
            .frame(width: cardWidth)
            

            HStack {
                Text(habit.isCheckedInToday ? "Checked in!" : "Tap to check in")
                    .frame(height: 60)
                    .multilineTextAlignment(.leading)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                CheckedInStateView(isCheckedIn: habit.isCheckedInToday, fontSize: 47)
                    .onTapGesture {
                        HapticManager.trigger(.success)
                        habit.toggleCheckIn(in: context)
                        scale += 0.075
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            scale -= 0.075
                        }
                    }
            }
            .frame(width: cardWidth)

            Text("\(habit.checkIns.count) / \(habit.duration.numberOfDays) days")
                .font(.subheadline)
                .foregroundStyle(.secondary)

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

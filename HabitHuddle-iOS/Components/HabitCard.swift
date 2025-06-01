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
    let cardWidth: CGFloat =  UIScreen.main.bounds.width / 2 - 24
    

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(habit.name)
                .font(.system(size: 20, weight: .semibold))
                .frame(maxHeight: 50)
                .multilineTextAlignment(.center)

            HStack {
                Text(habit.isCheckedInToday ? "Checked in!" : "Tap to check in")
                    .frame(height: 60)
                    .multilineTextAlignment(.leading)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                CheckedInStateView(isCheckedIn: habit.isCheckedInToday, fontSize: 47)
                    .onTapGesture {
                        habit.toggleCheckIn(in: context)
                        scale += 0.075
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            scale -= 0.075
                        }
                    }
            }

            Text("\(habit.checkIns.count) / \(habit.duration.numberOfDays)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                    .cornerRadius(4)

                Rectangle()
                    .fill(Color.blue)
                    .frame(width: cardWidth * CGFloat(habit.checkIns.count) / CGFloat(habit.duration.numberOfDays), height: 8)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
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

//
//  HabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI

struct HabitCard: View {
    let habit: Habit
    let cardWidth: CGFloat =  UIScreen.main.bounds.width / 2 - 32
    let habitProgress: CGFloat = 0.25
    @State private var isCheckedIn: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(habit.name)
                .font(.system(size: 20, weight: .semibold))
                .frame(maxHeight: 50)
                .multilineTextAlignment(.center)

            CheckedInStateView(isCheckedIn: $isCheckedIn)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isCheckedIn.toggle()
                    }
                }
                .frame(width: 50, height: 50)

            Text("Frequency: \(habit.frequency)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("4/16")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                    .cornerRadius(4)

                Rectangle()
                    .fill(Color.blue)
                    .frame(width: cardWidth * habitProgress, height: 8)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .frame(maxWidth: cardWidth)
        .frame(maxHeight: 225)
    }
}

#Preview {
    let habit = Habit(id: UUID(), user: LightweightUser(id: UUID()), name: "Demo Habit", description: "This is some description", frequency: .daily)
    VStack {
        HStack(spacing: 16) {
            HabitCard(habit: habit)
        }
    }
}

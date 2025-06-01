//
//  CheckInCardView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 30.05.25.
//

import SwiftUI

struct CheckInCardView: View {
    
    @Environment(\.modelContext) private var context
    @State private var scale = 1.0
    let habit: Habit
    let action: () -> ()

    var body: some View {
        Button {
            HapticManager.trigger(.success)
            habit.toggleCheckIn(in: context)
            action()
            scale += 0.1
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                scale -= 0.1
            }
        } label: {
            VStack(spacing: 16) {
                HStack {
                    AnimatableRing(habit: habit)
                        .frame(width: 175, height: 175)
                        .scaleEffect(scale)
                        .animation(.easeInOut(duration: 0.2), value: scale)
                }
                Text(habit.isCheckedInToday ? "You're all set for today!" : "Tap to Check In")
                    .font(.headline)
                    .foregroundStyle(habit.isCheckedInToday ? .green : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CheckInCardView(habit: Habit(id: UUID(), user: LightweightUser(id: UUID()), name: "New Habit", description: "Some description", duration: .oneMonth, reminderTime: .now, createdAt: .now, updatedAt: .now), action: {})
}

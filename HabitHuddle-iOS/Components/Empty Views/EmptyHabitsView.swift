//
//  EmptyHabitsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.05.25.
//

import SwiftUI

import SwiftUI

struct EmptyHabitsView: View {
    var onAddHabit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(.gray.opacity(0.4))

            Text("No habits yet")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.7))

            Text("Start building your daily routines to see your progress here.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: onAddHabit) {
                Text("Add your first habit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: 220)
                    .background(Color(.systemBlue))
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    EmptyHabitsView(onAddHabit: {})
}

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
            Image(systemName: "leaf")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(.green.opacity(0.6))
            
            Text("No habits yet")
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary.opacity(0.7))
            
            Text("Start building your daily routines to see your progress here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: onAddHabit) {
                Text("Add your first habit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 220)
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
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

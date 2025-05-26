//
//  HabitsGridView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.25.
//

import SwiftUI

struct HabitsGridView: View {
    let habits: [Habit]
    
    // 2-column grid layout
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(habits) { habit in
                HabitCard(
                    title: habit.name,
                    cardWidth: UIScreen.main.bounds.width / 2 - 32,
                    habitProgress: 0.25,
                    frequency: habit.frequency.rawValue
                )
            }
        }
        .padding()
    }
}

#Preview {
    HabitsGridView(habits: [])
}

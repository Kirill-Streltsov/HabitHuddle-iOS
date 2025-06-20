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
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(habits, id: \.self) { habit in
                NavigationLink(value: habit) {
                    HabitCard(habit: habit)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}

#Preview {
    HabitsGridView(habits: [])
}

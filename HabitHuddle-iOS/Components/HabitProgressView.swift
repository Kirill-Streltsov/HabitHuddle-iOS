//
//  HabitProgressView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct HabitProgressView: View {
    
    let habit: Habit
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = 4
    var color: Color = Color.gray.opacity(0.3)
    
    @State private var calculatedProgress: Double = 0.0
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(color)
                .frame(width: width, height: height)
                .cornerRadius(cornerRadius)

            Rectangle()
                .fill(Color.green)
                .frame(width: width * CGFloat(calculatedProgress), height: height)
                .cornerRadius(cornerRadius)
        }
        .onChange(of: habit.checkIns.count, { oldValue, newValue in
            animateBar()
        })
        .onAppear {
            animateBar()
        }
    }
    
    private func animateBar() {
        withAnimation(.easeOut) {
            calculatedProgress = CGFloat(habit.checkIns.count) / CGFloat(habit.duration.numberOfDays)
        }
    }
}

#Preview {
    HabitProgressView(habit: Habit(id: UUID(), user: LightweightUser(id: UUID()), name: "Drink water", description: "2 liters a day", duration: .oneMonth, reminderTime: .now, createdAt: .now, updatedAt: .now), width: 50, height: 50)
}

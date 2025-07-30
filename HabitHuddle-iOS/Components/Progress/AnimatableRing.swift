//
//  AnimatableRing.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 31.05.25.
//

import SwiftUI

struct AnimatableRing: View {
    let habit: Habit
    @State private var progress: CGFloat = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)

            RingShape(progress: progress)
                .stroke(
                    .green,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            Text("\(habit.checkIns.count)/\(habit.duration.numberOfDays) days")
                .contentTransition(.numericText())
                .font(.title2)
                .fontWeight(.semibold)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                calculateProgress()
            }
        }
        .onChange(of: habit.checkIns.count) { _, _ in
            withAnimation(.easeOut(duration: 0.5)) {
                calculateProgress()
            }
        }
        .onChange(of: habit.duration) { _, _ in
            withAnimation(.easeOut(duration: 0.5)) {
                calculateProgress()
            }
        }
    }

    private func calculateProgress() {
        progress = CGFloat(habit.checkIns.count) / CGFloat(habit.duration.numberOfDays)
    }
}

struct RingShape: Shape {
    var progress: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360 * progress),
                    clockwise: false)
        return path
    }

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
}

#Preview {
    let habit = Habit(id: UUID(), user: LightweightUser(id: UUID()), name: "Drink water", description: "Gotta stay hydrated", duration: .oneMonth, reminderTime: nil, createdAt: .now, updatedAt: .now)
    AnimatableRing(habit: habit)
}

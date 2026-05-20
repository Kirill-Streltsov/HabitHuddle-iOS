//
//  HabitDTOProgressView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 06.07.25.
//

import SwiftUI

struct HabitDTOProgressView: View {
    let habit: HabitDTO
    let height: CGFloat
    var cornerRadius: CGFloat = 4
    var color: Color = Color.gray.opacity(0.3)

    @State private var calculatedProgress: Double = 0.0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(color)
                    .frame(width: geo.size.width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

                Rectangle()
                    .fill(Color.green)
                    .frame(width: geo.size.width * CGFloat(calculatedProgress), height: height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
        }
        .frame(height: height)
        .onAppear {
            animateBar()
        }
    }

    private func animateBar() {
        withAnimation(.easeOut) {
            guard let checkIns = habit.checkIns else { return }
            if checkIns.count <= habit.duration.numberOfDays {
                calculatedProgress = CGFloat(checkIns.count) / CGFloat(habit.duration.numberOfDays)
            } else {
                calculatedProgress = 1.0
            }
        }
    }
}

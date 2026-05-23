//
//  CircularProgressView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.26.
//

import SwiftUI

// MARK: - Preview

#Preview("0%") {
    CircularProgressView(progress: 0).frame(width: 60, height: 60).padding()
}

#Preview("50%") {
    CircularProgressView(progress: 0.5).frame(width: 60, height: 60).padding()
}

#Preview("100%") {
    CircularProgressView(progress: 1).frame(width: 60, height: 60).padding()
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemBackground), lineWidth: 3.5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progress == 1 ? Color.green : Color.accentColor,
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
            Text("\(Int(progress * 100))%")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(progress == 1 ? .green : .primary)
        }
    }
}

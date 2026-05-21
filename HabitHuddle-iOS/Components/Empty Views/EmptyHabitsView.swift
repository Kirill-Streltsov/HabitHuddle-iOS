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
        CardView {
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(.gray.opacity(0.4))

                Text(.noHabitsYet)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary.opacity(0.7))

                Text(.createOneNow)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button(action: onAddHabit) {
                    Text(.addYourFirstHabit)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: 220)
                        .background(Color(.systemBlue))
                        .cornerRadius(12)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

#Preview {
    EmptyHabitsView(onAddHabit: {})
}

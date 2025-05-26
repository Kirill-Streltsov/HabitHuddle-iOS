//
//  HabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI

struct HabitCard: View {
    
    let title: String
    let cardWidth: CGFloat
    let habitProgress: CGFloat
    let isCheckedInToday: Bool
    
    let frequency: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .frame(maxHeight: 50)
                .multilineTextAlignment(.center)
            
            if isCheckedInToday {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 50))
            } else {
                UntrackedHabitCheckmark()
                    .foregroundStyle(.gray)
                    .font(.system(size: 50))
            }

            Text("Frequency: \(frequency)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("4/16")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: cardWidth * habitProgress, height: 8)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .frame(maxWidth: cardWidth)
        .frame(maxHeight: 225)
    }
}

#Preview {
    VStack {
        HStack(spacing: 16) {
            HabitCard(
                title: "Ride a bycicle",
                cardWidth: 175,
                habitProgress: 0.25,
                isCheckedInToday: true,
                frequency: "Daily",
            )
            HabitCard(
                title: "Drink water",
                cardWidth: 175,
                habitProgress: 0.25,
                isCheckedInToday: true,
                frequency: "Daily",
            )
        }
        HStack(spacing: 16) {
            HabitCard(
                title: "Eat a lot of protein",
                cardWidth: 175,
                habitProgress: 0.25,
                isCheckedInToday: true,
                frequency: "Daily",
            )
            HabitCard(
                title: "Drink water",
                cardWidth: 175,
                habitProgress: 0.25,
                isCheckedInToday: true,
                frequency: "Daily",
            )
        }
    }
}

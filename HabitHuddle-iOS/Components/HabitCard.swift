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
    @State private var isCheckedIn: Bool = false
    
    let frequency: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .frame(maxHeight: 50)
                .multilineTextAlignment(.center)
            
            CheckedInStateView(isCheckedIn: $isCheckedIn)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isCheckedIn.toggle()
                    }
                }
                .frame(width: 50, height: 50)

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
                frequency: "Daily",
            )
            HabitCard(
                title: "Drink water",
                cardWidth: 175,
                habitProgress: 0.25,
                frequency: "Daily",
            )
        }
        HStack(spacing: 16) {
            HabitCard(
                title: "Eat a lot of protein",
                cardWidth: 175,
                habitProgress: 0.25,
                frequency: "Daily",
            )
            HabitCard(
                title: "Drink water",
                cardWidth: 175,
                habitProgress: 0.25,
                frequency: "Daily",
            )
        }
    }
}

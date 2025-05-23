//
//  HabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI

struct HabitCard: View {
    let cardWidth: CGFloat
    let habitProgress: CGFloat
    let isCheckedInToday: Bool
    
    let frequency: String
    let nextCheckIn: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Drink water")
                        .font(.headline)
                    Text("Streak: 14")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("Frequency: \(frequency)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isCheckedInToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 50))
                } else {
                    UntrackedHabitCheckmark()
                        .foregroundStyle(.gray)
                        .font(.system(size: 50))
                }
            }
            
            Text("Days completed: 4/16")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            
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
            
            Text("Next check-in: \(nextCheckIn)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .frame(maxWidth: cardWidth)
    }
}

#Preview {
    HabitCard(
        cardWidth: 275,
        habitProgress: 0.25,
        isCheckedInToday: true,
        frequency: "Daily",
        nextCheckIn: "Today, 8 PM"
    )
}

//
//  HabitStatsCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct HabitStatsCard: View {
    let habit: Habit
    
    // Computed properties for some quick stats
    var totalCheckIns: Int {
        habit.checkIns.count
    }
    
    var longestStreak: Int {
        // Simple example: count max consecutive days from checkIns dates (assume sorted)
        let dates = habit.checkIns.map { Calendar.current.startOfDay(for: $0.date) }.sorted()
        guard !dates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<dates.count {
            let diff = Calendar.current.dateComponents([.day], from: dates[i-1], to: dates[i]).day ?? 0
            if diff == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else if diff > 1 {
                currentStreak = 1
            }
        }
        return maxStreak
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(habit.name)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.green)
                    .imageScale(.large)
            }
            
            Text(habit.habitDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Divider()
            
            HStack(spacing: 24) {
                StatItem(title: "Total Check-Ins", value: "\(totalCheckIns)")
                StatItem(title: "Longest Streak", value: "\(longestStreak) days")
                StatItem(title: "Completion", value: "\(completionPercentage)%")
            }
            
            ProgressView(value: 0.72)
                .tint(.green)
                .progressViewStyle(LinearProgressViewStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
        )
        .padding(.horizontal)
        .buttonStyle(.plain)
    }
    
    private var completionPercentageDouble: Double {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: habit.createdAt, to: .now).day ?? 1
        return daysSinceStart == 0 ? 0 : Double(totalCheckIns) / Double(daysSinceStart)
    }
    
    private var completionPercentage: Int {
        Int(completionPercentageDouble * 100)
    }
}

fileprivate struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let habit = Habit(id: UUID(), user: LightweightUser(id: UUID()), name: "This is a new habit", description: "Some description", duration: .oneWeek)
    HabitStatsCard(habit: habit)
}

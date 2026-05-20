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

    private var missedDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.startOfDay(for: habit.createdAt)

        // Total days from createdAt to today (inclusive)
        guard let totalDays = calendar.dateComponents([.day], from: startDate, to: today).day else {
            return 0
        }

        // Create a Set of check-in dates normalized to day
        let checkInDays: Set<Date> = Set(habit.checkIns.map { calendar.startOfDay(for: $0.date) })

        // Iterate over each day and count days without check-in
        var missed = 0
        for dayOffset in 0 ... totalDays {
            if let dateToCheck = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                if !checkInDays.contains(dateToCheck) {
                    missed += 1
                }
            }
        }
        return missed
    }

    private var completionPercentage: Int {
        let completionPercentageDouble = Double(habit.checkIns.count) / Double(habit.duration.numberOfDays)
        return Int(completionPercentageDouble * 100)
    }

    private var longestStreak: Int {
        // Simple example: count max consecutive days from checkIns dates (assume sorted)
        let dates = habit.checkIns.map { Calendar.current.startOfDay(for: $0.date) }.sorted()
        guard !dates.isEmpty else { return 0 }

        var maxStreak = 1
        var currentStreak = 1

        for i in 1 ..< dates.count {
            let diff = Calendar.current.dateComponents([.day], from: dates[i - 1], to: dates[i]).day ?? 0
            if diff == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else if diff > 1 {
                currentStreak = 1
            }
        }
        return maxStreak
    }

    @State private var progress: Double = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                HStack {
                    Text(habit.name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(habit.checkIns.isEmpty ? Color(.secondaryLabel) : Color.green)
                        .imageScale(.large)
                }

                Text(habit.habitDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Divider()

            HStack(spacing: 24) {
                StatItem(title: .totalCheckIns, value: "\(totalCheckIns)")
                StatItem(title: .longestStreak, value: .days(longestStreak))
                StatItem(title: .completion, value: "\(completionPercentage)%")
            }

            ProgressView(value: progress)
                .tint(.green)
                .progressViewStyle(LinearProgressViewStyle())
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.8)) {
                            progress = CGFloat(habit.checkIns.count) / CGFloat(habit.duration.numberOfDays)
                        }
                    }
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        )
        .padding(.horizontal)
        .buttonStyle(.plain)
    }
}

struct StatItem: View {
    let title: LocalizedStringResource
    let value: LocalizedStringResource

    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .contentTransition(.numericText())
                .font(.headline)
                .foregroundStyle(.primary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let habit = Habit(id: UUID(), user: LightweightUser(id: UUID()), name: "This is a new habit", description: "Some description", duration: .oneWeek)
    HabitStatsCard(habit: habit)
}

//
//  StatisticsDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 31.05.25.
//

import Charts
import SwiftUI

struct Streak {
    let length: Int
    let startDate: Date
    let endDate: Date
}

struct HourlyPatternData: Identifiable {
    let id = UUID()
    let hour: Int
    let count: Int
}

struct StreakData: Identifiable {
    let id = UUID()
    let date: Date
    let streakLength: Int
}


// MARK: - Main Statistics View

struct HabitStatisticsView: View {
    
    @State private var statisticsID = UUID()
    let habit: Habit
    
    // MARK: Computed properties

    private var hourlyData: [HourlyPatternData] {
        generateHourlyData()
    }
    
    private var streakData: [StreakData] {
        generateStreakData()
    }
    
    private var totalDays: Int {
        let days = Calendar.current.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 1
        return max(days, 1)
    }

    private var completionRate: Double {
        (Double(habit.checkIns.count) / Double(habit.duration.numberOfDays)) * 100
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

    // Calculate longest consecutive streak
    private var longestStreak: Streak {
        let calendar = Calendar.current
        let sortedCheckIns = habit.checkIns.map { calendar.startOfDay(for: $0.date) }.sorted()
        guard !sortedCheckIns.isEmpty else {
            return Streak(length: 0, startDate: Date(), endDate: Date())
        }

        var maxLength = 1
        var currentLength = 1
        var maxStart = sortedCheckIns[0]
        var currentStart = sortedCheckIns[0]

        for i in 1 ..< sortedCheckIns.count {
            let diff = calendar.dateComponents([.day], from: sortedCheckIns[i - 1], to: sortedCheckIns[i]).day ?? 0
            if diff == 1 {
                currentLength += 1
            } else if diff > 1 {
                if currentLength > maxLength {
                    maxLength = currentLength
                    maxStart = currentStart
                }
                currentStart = sortedCheckIns[i]
                currentLength = 1
            }
        }

        // Check last streak
        if currentLength > maxLength {
            maxLength = currentLength
            maxStart = currentStart
        }

        let maxEnd = calendar.date(byAdding: .day, value: maxLength - 1, to: maxStart) ?? maxStart
        return Streak(length: maxLength, startDate: maxStart, endDate: maxEnd)
    }

    // Calculate current streak ending today (or yesterday if missed today)
    private var currentStreak: Streak {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sortedDates = habit.checkIns.map { calendar.startOfDay(for: $0.date) }.sorted(by: >)

        var streak = 0
        var expectedDate = today

        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: expectedDate) {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if date < expectedDate {
                break
            }
        }

        let startDate = calendar.date(byAdding: .day, value: -(streak - 1), to: today) ?? today

        return Streak(length: streak, startDate: startDate, endDate: today)
    }

    private var checkInTimeDistribution: [(date: Date, hour: Int)] {
        let calendar = Calendar.current
        let filteredCheckIns = habit.checkIns.sorted(by: { $0.date < $1.date })

        return filteredCheckIns.map { checkIn in
            (
                date: calendar.startOfDay(for: checkIn.date),
                hour: calendar.component(.hour, from: checkIn.date)
            )
        }
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                let remaining = 2 - habit.checkIns.count
                CardView {
                    ChartContainerView(title: "Check in overview", subtitle: "Frequency of your check ins") {
                        HeatmapHabitView(habit: habit)
                            .id(statisticsID)
                    }
                }
                                
                if habit.checkIns.count >= 2 {
                    CardView {
                        ChartContainerView(title: "Streaks Timeline", subtitle: "Your streaks over time") {
                            streaksSection
                        }
                    }
                    
                    CardView {
                        ChartContainerView(title: "Time of Day Pattern", subtitle: "When you usually check in") {
                            checkInTimeDistributionSection
                        }
                    }
                } else {
                    Text("Check in \(remaining) more \(remaining == 1 ? "time" : "times") to unlock your streak data and discover your usual check-in time!")
                        .font(.body)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding()
                }
                
                CardView {
                    ChartContainerView(title: "Missed days", subtitle: "The number of days you've missed") {
                        missedDaysSection
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom)
        }
        .onChange(of: habit.checkIns.count) { _, _ in
            statisticsID = UUID()
        }
    }

    private var missedDaysSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Chart {
                    SectorMark(
                        angle: .value("Checked In", Double(habit.checkIns.count)),
                        innerRadius: .ratio(0.6)
                    )
                    .foregroundStyle(
                        Color.green
                    )
                    
                    SectorMark(
                        angle: .value("Missed", Double(missedDays)),
                        innerRadius: .ratio(0.6)
                    )
                    .foregroundStyle(
                        Color.pink
                    )
                }
                .frame(height: 140)
                Text("\(missedDays)")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            if missedDays == 0 {
                Text("100% consistency!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }

    private var streaksSection: some View {
        VStack(spacing: 24) {
            Chart(streakData) { data in
                AreaMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Streak", data.streakLength)
                )
                .foregroundStyle(Color.orange.gradient.opacity(0.3))
                
                LineMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Streak", data.streakLength)
                )
                .foregroundStyle(Color.orange)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 150)
    
            if currentStreak.length == longestStreak.length {
                Text("You're making great progress — this is your longest streak so far.")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            HStack(alignment: .top, spacing: 40) {
                VStack {
                    Text("Current Streak")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(currentStreak.length) days")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                    Text("From \(currentStreak.startDate.formatted(date: .numeric, time: .omitted)) to \(currentStreak.endDate.formatted(date: .numeric, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 120)
                }

                VStack {
                    Text("Longest Streak")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(longestStreak.length) days")
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                    Text("From \(longestStreak.startDate.formatted(date: .numeric, time: .omitted)) to \(longestStreak.endDate.formatted(date: .numeric, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 120)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var checkInTimeDistributionSection: some View {
        Chart(hourlyData) { data in
            BarMark(
                x: .value("Hour", data.hour),
                y: .value("Count", data.count)
            )
            .foregroundStyle(Color.purple.gradient)
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 4)) { value in
                AxisValueLabel {
                    if let hour = value.as(Int.self) {
                        Text(formatHour(hour))
                    }
                }
            }
        }
        .frame(height: 150)
    }

    private func generateHourlyData() -> [HourlyPatternData] {
        let calendar = Calendar.current
        var hourCounts = Array(repeating: 0, count: 24)
        
        for checkIn in habit.checkIns {
            let hour = calendar.component(.hour, from: checkIn.date)
            hourCounts[hour] += 1
        }
        
        return hourCounts.enumerated().map { index, count in
            HourlyPatternData(hour: index, count: count)
        }
    }

    private func formatHour(_ hour: Int) -> String {
        if hour == 0 { return "12AM" }
        if hour < 12 { return "\(hour)AM" }
        if hour == 12 { return "12PM" }
        return "\(hour - 12)PM"
    }
    
    private func generateStreakData() -> [StreakData] {
        let calendar = Calendar.current
        let checkInDates = habit.checkIns.map { calendar.startOfDay(for: $0.date) }.sorted()
        
        guard !checkInDates.isEmpty else { return [] }
        
        var streakData: [StreakData] = []
        var currentStreak = 1
        var lastDate = checkInDates[0]
        
        streakData.append(StreakData(date: lastDate, streakLength: currentStreak))
        
        for i in 1..<checkInDates.count {
            let currentDate = checkInDates[i]
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: currentDate).day ?? 0
            
            if daysBetween == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            
            streakData.append(StreakData(date: currentDate, streakLength: currentStreak))
            lastDate = currentDate
        }
        
        return streakData
    }
}

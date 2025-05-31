//
//  StatisticsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 31.05.25.
//

import SwiftUI
import Charts

struct Streak {
    let length: Int
    let startDate: Date
    let endDate: Date
}

// MARK: - Main Statistics View

struct StatisticsView: View {
    
    let habit: Habit
    
    // MARK: Computed properties
    
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
        for dayOffset in 0...totalDays {
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
        
        for i in 1..<sortedCheckIns.count {
            let diff = calendar.dateComponents([.day], from: sortedCheckIns[i-1], to: sortedCheckIns[i]).day ?? 0
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
    private var currentStreak: Int {
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
        return streak
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
    
    private var missedDaysText: String {
        if missedDays > 0 {
            if missedDays == 1 {
                if totalDays == 1 {
                    return "Check into your habit ⚡️"
                } else {
                    return "You have missed 1 day\nStill no reason to give up!"
                }
                
            } else {
                return "\(missedDays) days missed out of \(totalDays)"
            }
        } else {
            return "You haven't missed a day!\nWell done 🎉"
        }
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    CardView {
                        VStack(alignment: .trailing) {
                            HStack {
                                completionRateSection
                                missedDaysSection
                            }
                            Text(missedDaysText)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                    }
                    CardView {
                        streaksSection
                    }
                    CardView {
                        checkInTimeDistributionSection
                    }
                }
            }
            .navigationTitle("Statistic")
        }
    }
    
    // MARK: Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack {
                    Text("+24%")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Keep up the amazing work! 🔥")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fontWeight(.light)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.green.opacity(0.8))
                    .font(.system(size: 75))
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    private var completionRateSection: some View {
        VStack(spacing: 8) {
            Text("Completion Rate")
                .font(.headline)
            
            ZStack {
                Chart {
                    SectorMark(
                        angle: .value("Completion", completionRate),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .foregroundStyle(Color.green.gradient)
                    
                    SectorMark(
                        angle: .value("Remaining", 100 - completionRate),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .foregroundStyle(Color.gray.opacity(0.25))
                }
                .frame(height: 140)
                Text(String(format: "%.0f%%", completionRate))
                    .font(.title)
                    .fontWeight(.semibold)
            }
        }
    }
    
    private var missedDaysSection: some View {
        VStack(spacing: 8) {
            Text("Missed Days")
                .font(.headline)
            
            Chart {
                SectorMark(
                    angle: .value("Checked In", Double(habit.checkIns.count)),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(
                    Color.green.gradient
                )
                
                SectorMark(
                    angle: .value("Missed", Double(missedDays)),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(
                    Color.red.gradient
                )
            }
            .frame(height: 140)
        }
    }
    
    private var streaksSection: some View {
        VStack(spacing: 8) {
            Text("Streaks")
                .font(.headline)
            
            HStack(alignment: .top, spacing: 40) {
                VStack {
                    Text("Current Streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(currentStreak) days")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    ProgressRing(progress: Double(currentStreak) / Double(longestStreak.length), color: .green)
                        .frame(width: 60, height: 60)
                }
                
                VStack {
                    Text("Longest Streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(longestStreak.length) days")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    Text("From \(longestStreak.startDate.formatted(date: .numeric, time: .omitted)) to \(longestStreak.endDate.formatted(date: .numeric, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 120)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var checkInTimeDistributionSection: some View {
        VStack(spacing: 8) {
            Text("Check-in Time Distribution")
                .font(.headline)
            
            Chart(checkInTimeDistribution, id: \.date) { data in
                BarMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Hour", data.hour)
                )
                .foregroundStyle(.blue)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 2)) { val in
                    AxisValueLabel {
                        if let date = val.as(Date.self) {
                            Text(date, format: Date.FormatStyle().day(.twoDigits))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: Array(stride(from: 0, through: 23, by: 3))) { value in
                    AxisValueLabel() {
                        if let hourDouble = value.as(Double.self) {
                            let hourInt = Int(hourDouble)
                            Text("\(hourInt):00")
                        } else {
                            Text("-")
                        }
                    }
                }
            }
            .frame(height: 200)
        }
    }
}

// MARK: - ProgressRing View for Streak visualization

struct ProgressRing: View {
    var progress: Double // 0...1
    var color: Color = .blue
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.25), lineWidth: 8)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}



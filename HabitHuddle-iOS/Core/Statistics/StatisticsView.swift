//
//  StatisticsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 31.05.25.
//

import SwiftUI

import SwiftUI
import Charts

// MARK: - Models for Chart Data

struct CheckInDayCount: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct Streak {
    let length: Int
    let startDate: Date
    let endDate: Date
}

// MARK: - Main Statistics View

struct StatisticsView: View {
    let habit: Habit

    @State private var selectedTimeRange: TimeRange = .month

    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"

        var id: String { rawValue }
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            }
        }
    }

    // MARK: Computed properties

    private var totalDays: Int {
        let days = Calendar.current.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 1
        return max(days, 1)
    }

    private var completionRate: Double {
        (Double(habit.checkIns.count) / Double(habit.duration.numberOfDays)) * 100
    }

    private var missedDays: Int {
        totalDays - habit.checkIns.count
    }

    private var checkInsInRange: [HabitCheckIn] {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
        return habit.checkIns.filter { $0.date >= cutoff }
    }

    private var dailyCheckIns: [CheckInDayCount] {
        let calendar = Calendar.current

        // Group checkIns by day within range
        let grouped = Dictionary(grouping: checkInsInRange) { checkIn in
            calendar.startOfDay(for: checkIn.date)
        }

        // Create array for all days in range, with zero if no checkins
        let daysRange = (0..<selectedTimeRange.days).compactMap { offset -> Date? in
            calendar.date(byAdding: .day, value: -offset, to: Date())
        }.reversed()

        return daysRange.map { date in
            CheckInDayCount(date: date, count: grouped[calendar.startOfDay(for: date)]?.count ?? 0)
        }
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

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection

                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                completionRateSection
                streaksSection
                missedDaysSection
                checkInTimeDistributionSection
                frequencyHeatmapSection
            }
            .padding()
            .navigationTitle(habit.name + " Statistics")
        }
    }

    // MARK: Sections

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text(habit.habitDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Created on \(habit.createdAt.formatted(date: .abbreviated, time: .omitted))")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }

    private var completionRateSection: some View {
        VStack(spacing: 8) {
            Text("Completion Rate")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

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
                .animation(.easeInOut, value: completionRate)

                Text(String(format: "%.0f%%", completionRate))
                    .font(.largeTitle.bold())
            }
        }
    }

    private var streaksSection: some View {
        VStack(spacing: 12) {
            Text("Streaks")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 40) {
                VStack {
                    Text("Current Streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(currentStreak) days")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    ProgressRing(progress: Double(currentStreak) / 30.0, color: .green)
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
    }

    private var missedDaysSection: some View {
        VStack(spacing: 8) {
            Text("Missed Days")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

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
                    angle: .value("Missed", Double(habit.duration.numberOfDays - habit.checkIns.count)),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(
                    Color.red.gradient
                    )
            }
            .frame(height: 140)

            Text("\(habit.duration.numberOfDays - habit.checkIns.count) days missed out of \(habit.duration.numberOfDays)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var checkInTimeDistribution: [(date: Date, hour: Int)] {
        let calendar = Calendar.current
        // Consider check-ins in the last 30 days only:
        let cutoff = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()

        // Filter and map habit.checkIns to tuples of (day, hour)
        // Use startOfDay to group check-ins by day (ignore time part)
        let filteredCheckIns = habit.checkIns.filter { $0.date >= cutoff }.sorted(by: { $0.date < $1.date })
        
        print("THESE ARE THE HOURS")
        for checkIn in filteredCheckIns {
            print("DAY: \(calendar.component(.day, from: checkIn.date)) HOUR: \(calendar.component(.hour, from: checkIn.date))")
        }
        

        return filteredCheckIns.map { checkIn in
            (
                date: calendar.startOfDay(for: checkIn.date),
                hour: calendar.component(.hour, from: checkIn.date)
            )
        }
    }

    private var checkInTimeDistributionSection: some View {
        VStack(spacing: 8) {
            Text("Check-in Time Distribution")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

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
                AxisMarks(values: Array(stride(from: 0, through: 23, by: 3))) // 0,3,6,...21,24
            }
            .frame(height: 200)
        }
    }

    // Placeholder: Implement a calendar heatmap here if you want
    private var frequencyHeatmapSection: some View {
        VStack(spacing: 8) {
            Text("Check-in Frequency Heatmap")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Feature coming soon...")
                .foregroundColor(.gray)
                .italic()
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



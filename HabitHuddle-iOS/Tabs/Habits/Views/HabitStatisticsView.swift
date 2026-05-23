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

        guard let totalDays = calendar.dateComponents([.day], from: startDate, to: today).day else {
            return 0
        }

        let checkInDays: Set<Date> = Set(habit.checkIns.map { calendar.startOfDay(for: $0.date) })

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

        if currentLength > maxLength {
            maxLength = currentLength
            maxStart = currentStart
        }

        let maxEnd = calendar.date(byAdding: .day, value: maxLength - 1, to: maxStart) ?? maxStart
        return Streak(length: maxLength, startDate: maxStart, endDate: maxEnd)
    }

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

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                let remaining = 2 - habit.checkIns.count
                CardView {
                    ChartContainerView(title: String(localized: .checkInOverview), subtitle: String(localized: .frequencyOfYourCheckIns)) {
                        HeatmapHabitView(habit: habit)
                            .id(statisticsID)
                    }
                }

                if habit.checkIns.count >= 2 {
                    CardView {
                        ChartContainerView(title: String(localized: .streaksTimeline), subtitle: String(localized: .yourStreaksOverTime)) {
                            streaksSection
                        }
                    }

                    CardView {
                        ChartContainerView(title: String(localized: .timeOfDayPattern), subtitle: String(localized: .whenYouUsuallyCheckIn)) {
                            checkInTimeDistributionSection
                        }
                    }
                } else {
                    Text(.checkInMoreTimesToUnlockYourStreakDataAndDiscoverYourUsualCheckInTime(remaining))
                        .font(.body)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding()
                }

                CardView {
                    ChartContainerView(title: String(localized: .missedDays), subtitle: String(localized: .theNumberOfDaysYouveMissed)) {
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
                        angle: .value(String(localized: .checkedIn), Double(habit.checkIns.count)),
                        innerRadius: .ratio(0.6)
                    )
                    .foregroundStyle(
                        Color.green
                    )

                    SectorMark(
                        angle: .value(String(localized: .missed), Double(missedDays)),
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
                Text(._100Consistency)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }

    private var streaksSection: some View {
        VStack(spacing: 24) {
            Chart(streakData) { data in
                BarMark(
                    x: .value(String(localized: .date), data.date, unit: .day),
                    y: .value(String(localized: .streak), data.streakLength)
                )
                .foregroundStyle(Color.orange.gradient)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 1)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 150)

            if currentStreak.length == longestStreak.length {
                Text(.youreMakingGreatProgressThisIsYourLongestStreakSoFar)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            HStack(alignment: .top, spacing: 40) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text(.currentStreak)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    Text(.days(currentStreak.length))
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                    Text(.fromTo(currentStreak.startDate.formatted(date: .numeric, time: .omitted), currentStreak.endDate.formatted(date: .numeric, time: .omitted)))
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 120)
                }

                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text(.longestStreak)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    Text(.days(longestStreak.length))
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                    Text(.fromTo(longestStreak.startDate.formatted(date: .numeric, time: .omitted), longestStreak.endDate.formatted(date: .numeric, time: .omitted)))
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
                x: .value(String(localized: .hour), data.hour),
                y: .value(String(localized: .count), data.count)
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

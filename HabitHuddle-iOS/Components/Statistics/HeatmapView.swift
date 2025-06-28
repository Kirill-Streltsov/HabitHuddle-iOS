//
//  HeatmapView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct HeatmapView: View {
    let habits: [Habit]

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .iso8601)
        cal.firstWeekday = 2 // Monday
        cal.timeZone = .current // ← important!
        return cal
    }()

    // Cache weekdays computation
    private let weekDays: [String] = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.shortWeekdaySymbols
        let cal = Calendar(identifier: .iso8601)
        let firstWeekdayIndex = cal.firstWeekday - 1
        if let symbols = symbols {
            return Array(symbols[firstWeekdayIndex ..< symbols.count]) + symbols[0 ..< firstWeekdayIndex]
        } else {
            return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        }
    }()

    @State private var checkInData: [Date: Int] = [:]
    @State private var computedWeeks: [[Date]] = []
    @State private var monthLabels: [Int: String] = [:]

    // Pre-compute all dates once
    private func computeAllDates() -> [Date] {
        let calendar = Calendar.current

        // Get today's date
        let today = Date()

        // Find the next Sunday (including today if it's already Sunday)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 1 // 1 = Sunday in Gregorian calendar

        // This gives us the nearest upcoming Sunday (or today if already Sunday)
        let upcomingSunday = calendar.nextDate(after: today, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) ?? today

        // Start date is 69 days before the upcoming Sunday
        let start = calendar.date(byAdding: .day, value: -83, to: upcomingSunday)!

        // Generate all dates from start to upcoming Sunday
        var date = start
        var dates: [Date] = []

        while date <= upcomingSunday {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        return dates
    }

    // Pre-compute weeks structure
    private func computeWeeks(from allDates: [Date]) -> [[Date]] {
        let grouped = Dictionary(grouping: allDates) { date in
            calendar.component(.weekOfYear, from: date) + calendar.component(.yearForWeekOfYear, from: date) * 100
        }

        return grouped
            .keys
            .sorted()
            .compactMap { grouped[$0]?.sorted() }
    }

    // Pre-compute month labels
    private func computeMonthLabels(for weeks: [[Date]]) -> [Int: String] {
        var labels: [Int: String] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        for (index, week) in weeks.enumerated() {
            if let date = week.first {
                let day = calendar.component(.day, from: date)
                if day >= 13 && day < 20 {
                    labels[index] = formatter.string(from: date)
                }
            }
        }
        return labels
    }

    private func color(for value: Int) -> Color {
        if habits.count == 1 {
            if value == 0 {
                return Color.gray.opacity(0.2)
            } else {
                return Color.green
            }
        } else {
            switch value {
            case 1: return .green.opacity(0.3)
            case 2...4: return .green.opacity(0.6)
            case 5...: return .green
            default: return .gray.opacity(0.1)
            }
        }
    }

    init(habits: [Habit]) {
        self.habits = habits
    }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            // Weekday labels
            VStack(alignment: .trailing, spacing: 4) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                        .frame(width: 30, height: 20)
                }
            }

            // Heatmap grid
            HStack(spacing: 4) {
                ForEach(computedWeeks.indices, id: \.self) { index in
                    let week = computedWeeks[index]
                    VStack(spacing: 4) {
                        ForEach(week, id: \.self) { date in
                            let dayKey = calendar.startOfDay(for: date)
                            let value = checkInData[dayKey] ?? 0
                            Rectangle()
                                .fill(color(for: value))
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)
                        }
                    }
                    .overlay(alignment: .top) {
                        if let label = monthLabels[index] {
                            Text(label)
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .frame(width: 30)
                                .offset(y: -16) // move it above the grid
                        }
                    }
                }
            }
        }
        .padding(.top)
        .onAppear {
            // Perform all heavy computations once
            let allDates = computeAllDates()
            computedWeeks = computeWeeks(from: allDates)
            monthLabels = computeMonthLabels(for: computedWeeks)
            
            // Process check-in data efficiently
            Task(priority: .background) {
                var tempCheckInData: [Date: Int] = [:]
                
                if habits.count == 1 {
                    // Use Set for O(1) lookup instead of iterating through array
                    let checkInDates = Set(habits[0].checkIns.map { calendar.startOfDay(for: $0.date) })
                    for date in allDates {
                        let day = calendar.startOfDay(for: date)
                        tempCheckInData[day] = checkInDates.contains(day) ? 1 : 0
                    }
                } else {
                    // Build lookup dictionary for all habits at once
                    var checkInCounts: [Date: Int] = [:]
                    for habit in habits {
                        for checkIn in habit.checkIns {
                            let day = calendar.startOfDay(for: checkIn.date)
                            checkInCounts[day, default: 0] += 1
                        }
                    }
                    
                    // Apply to all dates
                    for date in allDates {
                        let day = calendar.startOfDay(for: date)
                        tempCheckInData[day] = checkInCounts[day] ?? 0
                    }
                }
                
                // Update on main thread
                await MainActor.run {
                    checkInData = tempCheckInData
                }
            }
        }
    }
}

#Preview {
    let habit = Habit.createTestHabitsWithCheckIns()[0]
    HeatmapView(habits: [habit])
}

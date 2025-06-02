//
//  HeatmapView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct HeatmapView: View {
    let habit: Habit

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .iso8601)
        cal.firstWeekday = 2 // Monday
        cal.timeZone = .current // ← important!
        return cal
    }()

    private var weekDays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.shortWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        if let symbols = symbols {
            return Array(symbols[firstWeekdayIndex ..< symbols.count]) + symbols[0 ..< firstWeekdayIndex]
        } else {
            return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        }
    }

    @State private var checkInData: [Date: Int] = [:]

    private var allDates: [Date] {
        let calendar = Calendar.current

        // Get today's date
        let today = Date()

        // Find the next Sunday (including today if it's already Sunday)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 1 // 1 = Sunday in Gregorian calendar

        // This gives us the nearest upcoming Sunday (or today if already Sunday)
        let upcomingSunday = calendar.nextDate(after: today, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) ?? today

        // Start date is 69 days before the upcoming Sunday
        let start = calendar.date(byAdding: .day, value: -69, to: upcomingSunday)!

        // Generate all dates from start to upcoming Sunday
        var date = start
        var dates: [Date] = []

        while date <= upcomingSunday {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        return dates
    }

    private var weeks: [[Date]] {
        let grouped = Dictionary(grouping: allDates) { date in
            calendar.component(.weekOfYear, from: date) + calendar.component(.yearForWeekOfYear, from: date) * 100
        }

        return grouped
            .keys
            .sorted()
            .compactMap { grouped[$0]?.sorted() }
    }

    private func color(for value: Int) -> Color {
//        switch value {
//        case 1: return .green.opacity(0.3)
//        case 2...4: return .green.opacity(0.6)
//        case 5...: return .green
//        default: return .gray.opacity(0.1)
//        }
        if value == 0 {
            return Color.gray.opacity(0.2)
        } else {
            return Color.green
        }
    }

    private func monthLabel(for date: Date?) -> String? {
        guard let date = date else { return nil }
        let day = calendar.component(.day, from: date)
        if day >= 13 && day < 20 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
        return nil
    }

    init(habit: Habit) {
        self.habit = habit
    }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            // Weekday labels
            VStack(alignment: .trailing, spacing: 4) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                        .frame(height: 20)
                }
            }

            // Heatmap grid
            HStack(spacing: 4) {
                ForEach(weeks.indices, id: \.self) { index in
                    let week = weeks[index]
                    VStack(spacing: 4) {
                        ForEach(week, id: \.self) { date in
                            let value = checkInData[calendar.startOfDay(for: date)] ?? 0
                            Rectangle()
                                .fill(color(for: value))
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)
                        }
                    }
                    .overlay(alignment: .top) {
                        if let label = monthLabel(for: week.first) {
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
        .padding()
        .onAppear {
            for checkIn in habit.checkIns {
                let day = calendar.startOfDay(for: checkIn.date)
                checkInData[day] = 1
            }
        }
    }
}

#Preview {
    let habit = Habit.createTestHabitsWithCheckIns()[0]
    HeatmapView(habit: habit)
}

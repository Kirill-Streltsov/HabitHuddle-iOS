//
//  HeatmapView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct HeatmapView: View {
    
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
            return Array(symbols[firstWeekdayIndex..<symbols.count]) + symbols[0..<firstWeekdayIndex]
        } else {
            return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        }
    }
    
    // MARK: - Hardcoded realistic data
    private var checkInData: [Date: Int] {
        var data: [Date: Int] = [:]
        let today = calendar.startOfDay(for: Date())
        
        for i in 0..<60 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let weekday = calendar.component(.weekday, from: date)
            
            let value: Int
            switch i {
            case 0...5: value = [1, 2, 4, 0, 3, 5][i]
            case 6...13: value = i % 3 == 0 ? 0 : 2
            case 14...20: value = i % 2 == 0 ? 3 : 1
            case 21...30: value = weekday == 1 ? 0 : 4
            case 31...45: value = [0, 1, 0, 2, 0, 1, 0][i % 7]
            case 46...60: value = i % 4 == 0 ? 5 : 0
            case 61...75: value = 2
            case 76...89: value = (i % 5 == 0 ? 0 : 1)
            default: value = 0
            }
            
            data[date] = value
        }
        
        for item in data.sorted(by: { $0.0 < $1.0 }) {
            print("DATE: \(item.key). CHECKINS: \(item.value)")
        }
        
        return data
    }
    
    private var allDates: [Date] {
        let start = calendar.date(byAdding: .day, value: -90, to: Date())!
        var date = start
        var dates: [Date] = []
        while date <= Date() {
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
        switch value {
        case 1: return .green.opacity(0.3)
        case 2...4: return .green.opacity(0.6)
        case 5...: return .green
        default: return .gray.opacity(0.1)
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
    
    var body: some View {
        ScrollView(.horizontal) {
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
        }
    }
}

#Preview {
    HeatmapView()
}

//
//  ChallengeDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 28.06.25.
//

import SwiftUI

import SwiftUI

struct ChallengeDetailView: View {
    let title: String
    let startDate: Date
    let endDate: Date
    let initiatorName: String
    let initiatorDates: [Date]
    let receiverName: String
    let receiverDates: [Date]
    
    private var dateRange: [Date] {
        Calendar.current.generateDates(from: startDate, to: endDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.largeTitle.weight(.bold))
                    .padding(.top)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    ForEach(dateRange, id: \.self) { date in
                        DayRow(
                            date: date,
                            initiatorName: initiatorName,
                            initiatorDates: initiatorDates,
                            receiverName: receiverName,
                            receiverDates: receiverDates)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct DayRow: View {
    let date: Date
    let initiatorName: String
    let initiatorDates: [Date]
    let receiverName: String
    let receiverDates: [Date]
    
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Date column
            VStack(alignment: .leading, spacing: 2) {
                Text(shortDate)
                    .font(.headline)
                Text(longDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60, alignment: .leading)
            
            personCheckView(personName: initiatorName, checkInDates: initiatorDates)
                .frame(maxWidth: .infinity, alignment: .center)
            
            personCheckView(personName: receiverName, checkInDates: receiverDates)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            calendar.isDateInToday(date)
                ? Color.blue.opacity(0.15)
                : Color(.systemBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private func personCheckView(personName: String, checkInDates: [Date]) -> some View {
        if let checkInDate = checkInDates.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            HStack(alignment: .center, spacing: 6) {
                Circle()
                    .fill(
                        .green
                    )
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(personName)
                        .font(.subheadline.weight(.semibold))
                    Text(timeFormatter.string(from: checkInDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        } else {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                    )
                
                Text(personName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var longDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
}

struct ChallengeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChallengeDetailView(
                title: "30-Day Fitness Challenge",
                startDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                endDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
                initiatorName: "Alex",
                initiatorDates: generateSampleDates(count: 10),
                receiverName: "Jordan",
                receiverDates: generateSampleDates(count: 7))
        }
    }
    
    static func generateSampleDates(count: Int) -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<count).compactMap { i in
            calendar.date(byAdding: .day, value: -i*2, to: today)
        }
    }
}

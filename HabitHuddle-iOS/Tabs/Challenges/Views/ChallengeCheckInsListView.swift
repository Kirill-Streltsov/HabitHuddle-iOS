//
//  ChallengeDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 28.06.25.
//

import SwiftUI

struct ChallengeCheckInsListView: View {

    let challenge: ChallengeDTO
    @State private var isLoading = true
    @StateObject private var viewModel = ViewModel()
    
    private var dateRange: [Date] {
        Calendar.current.generateDates(from: challenge.startDate, to: challenge.endDate)
    }
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView(String(localized: .loadingCheckIns))
                        .frame(maxWidth: .infinity)
                        .padding()
            } else {
                VStack(spacing: 8) {
                    Text(.challengeTimeline)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.bottom)
                    ForEach(dateRange, id: \.self) { date in
                        DayRow(
                            date: date,
                            initiatorName: challenge.initiator.user.name,
                            initiatorDates: viewModel.initiatorDates,
                            receiverName: challenge.receiver.user.name,
                            receiverDates: viewModel.receiverDates)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .task {
            isLoading = true
            if let initiatorHabitID = challenge.initiatorHabitID,
               let receiverHabitID = challenge.receiverHabitID {
                await viewModel.getCheckInDates(for: initiatorHabitID, and: receiverHabitID)
            }
            isLoading = false
        }
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
            ChallengeCheckInsListView(
                challenge: ChallengeDTO(
                    id: UUID(),
                    initiatorHabitID: UUID(),
                    receiverHabitID: UUID(),
                    habitName: "",
                    startDate: .now,
                    endDate: .now,
                    status: .accepted,
                    initiator: .init(
                        user: .init(
                            id: UUID(),
                            username: "",
                            name: "",
                            createdAt: .now,
                            updatedAt: .now),
                        progress: 0,
                        checkInCount: 0,
                        plannedDays: 0),
                    receiver: .init(
                        user: .init(
                            id: UUID(),
                            username: "",
                            name: "",
                            createdAt: .now,
                            updatedAt: .now),
                        progress: 0,
                        checkInCount: 0,
                        plannedDays: 0)))
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

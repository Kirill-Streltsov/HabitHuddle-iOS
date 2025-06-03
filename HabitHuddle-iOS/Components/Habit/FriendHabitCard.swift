//
//  FriendHabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//


import SwiftUI

struct FriendHabitCard: View {
    let habit: Habit
    let cardWidth: CGFloat = UIScreen.main.bounds.width - 32
    
    @State private var showActionSheet = false
    @State private var selectedOption = ""

    // Date formatter for display
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }

    private var checkInsLast30DaysCount: Int {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        return habit.checkIns.filter { $0.date >= thirtyDaysAgo }.count
    }

    private var progressRatio: CGFloat {
        min(CGFloat(habit.checkIns.count) / CGFloat(habit.duration.numberOfDays), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Name + Reminder
            HStack {
                Text(habit.name)
                    .font(.title2.bold())
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Spacer()
                Image(systemName: habit.reminderTime != nil ? "bell.fill" : "bell.slash.fill")
                    .foregroundStyle(habit.reminderTime != nil ? .orange : .gray)
            }

            // Description
            if !habit.habitDescription.isEmpty {
                Text(habit.habitDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            // Duration & Progress
            HStack {
                Label(habit.duration.displayName, systemImage: "timer")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Spacer()

                Label("\(habit.checkIns.count) / \(habit.duration.numberOfDays) check-ins", systemImage: "checkmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.green)
            }

            // Progress bar + percent text
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 14)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.green)
                    .frame(width: cardWidth * progressRatio, height: 14)
            }
            .overlay(
                Text(String(format: "%.0f%%", progressRatio * 100))
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6),
                alignment: .center
            )

            // Created / Updated info
            HStack {
                VStack(alignment: .leading) {
                    Text("Created:")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(dateFormatter.string(from: habit.createdAt))
                        .font(.caption)
                }
                Spacer()
                SlimButton(title: "Challenge") {
                    showActionSheet = true
                }
                    .confirmationDialog("Choose the challenge type", isPresented: $showActionSheet, titleVisibility: .visible) {
                        Button("Supportive") { selectedOption = "Supportive" }
                        Button("Competitive", role: .destructive) { selectedOption = "Competitive" }
                        Button("Cancel", role: .cancel) { }
                    }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Updated:")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(dateFormatter.string(from: habit.updatedAt))
                        .font(.caption)
                }
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .frame(maxWidth: cardWidth)
        .padding(.horizontal)
    }
}

#Preview {
    FriendHabitCard(habit: Habit.demoHabitWithRecentCheckIns())
}

//
//  HabitDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftData
import SwiftUI
import UserNotifications

struct HabitDetailView: View {
    var habit: Habit?

    @State private var isCheckedIn = false
    @State private var deleteButtonPressed = false
    @State private var showEditSheet = false
    
    @StateObject private var viewModel: ViewModel
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: LocalUserManager

    init(habit: Habit? = nil) {
        _viewModel = StateObject(wrappedValue: ViewModel())
        self.habit = habit
    }

    var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    if let habit = habit {
                        VStack(spacing: 12) {
                            habitHeader(habit: habit)
                            CheckInCardView(habit: habit) {
                                checkIntoHabit(habit)
                            }
                            HabitStatisticsView(habit: habit)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showEditSheet) {
                HabitEditView(viewModel: viewModel)
            }
            .navigationTitle(viewModel.name)
            .toolbar {
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                Button {
                    deleteButtonPressed = true
                    Task {
                        await deleteHabit()
                    }
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
            .onAppear {
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("⏰ Pending notifications:")
                    for request in requests {
                        print("• \(request.identifier) — \(request.content.body)")
                    }
                }
                if let habit = habit {
                    populateFields(with: habit)
                    isCheckedIn = habit.isCheckedInToday
                    viewModel.habit = habit
                }
            }
            .onChange(of: viewModel.duration) { _, newValue in
                if let habit = habit {
                    Task {
                        await MainActor.run {
                            habit.duration = newValue
                            try? context.save()
                        }
                    }
                }
            }
    }
    
    private func habitHeader(habit: Habit) -> some View {
        VStack(spacing: 0) {
            Text(habit.habitDescription)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .padding(.horizontal)
            Image(systemName: habit.icon ?? "")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(12)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func populateFields(with habit: Habit) {
        viewModel.name = habit.name
        viewModel.description = habit.habitDescription
        viewModel.icon = habit.icon
        viewModel.duration = habit.duration
        if let reminderTime = habit.reminderTime {
            viewModel.reminderTime = reminderTime
            viewModel.hasReminder = true
        } else {
            viewModel.hasReminder = false
        }
    }

    private func checkIntoHabit(_ habit: Habit) {
        Task {
            if userManager.profile.isSignedInToServer {
                let result = await viewModel.checkIntoHabit(with: habit.id)
                Helpers.handleResult(result) { checkedIn in
                    print("✅ The user has checked in: \(checkedIn)")
                } onFailure: { error in
                    print("❌ Error: Posting the check in: \(error)")
                }
            }
        }
    }

    private func deleteHabit() async {
        guard let habit = habit else { return }
        context.delete(habit)
        try? context.save()
        
        Task {
            if userManager.profile.isSignedInToServer {
                let result = await viewModel.deleteHabit(with: habit.id)
                Helpers.handleResult(result) { codableHabit in
                    print("✅ Deleted the habit on the server with habit name: '\(codableHabit.name)' and id: '\(codableHabit.id)'")
                } onFailure: { error in
                    print("❌ Error: Failed to delete the habit on the server: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    HabitDetailView()
}

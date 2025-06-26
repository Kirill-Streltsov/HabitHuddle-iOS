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
    enum Mode {
        case editing
        case adding
    }

    var habit: Habit?
    var isPartOfChallenge: Bool {
        if let habit = habit, !habit.challenges.isEmpty {
            return true
        } else {
            return false
        }
    }
    let mode: Mode

    @State private var isCheckedIn = false
    @State private var saveButtonPressed = false
    @State private var deleteButtonPressed = false
    @State private var showEditSheet = false
    
    @StateObject private var viewModel: ViewModel
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: LocalUserManager

    init(habit: Habit? = nil) {
        _viewModel = StateObject(wrappedValue: ViewModel())
        self.habit = habit
        mode = habit == nil ? .adding : .editing
    }

    var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    if mode == .adding {
                        Text("Create a new habit")
                            .font(.largeTitle.weight(.semibold))
                    }
                    if mode == .editing {
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
                    } else {
                        editHabitView
                    }
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showEditSheet) {
                editHabitView
            }
            .toolbar {
                if let icon = viewModel.icon {
                    ToolbarItem(placement: .principal) {
                        Image(systemName: icon)
                    }
                }
            }
            .toolbar {
                if mode == .editing {
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
            .onDisappear {
                syncWithServerBeforeQuitting()
            }
    }
    
    private func habitHeader(habit: Habit) -> some View {
        VStack(spacing: 8) {
            Text(habit.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(habit.habitDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }
    
    private var editHabitView: some View {
        VStack(spacing: 16) {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        CustomStyledTextField(
                            placeholder: "Habit name",
                            text: $viewModel.name
                        )
                        
                        CustomStyledTextField(
                            placeholder: "Description (optional)",
                            text: $viewModel.description
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose an Icon")
                            .fontWeight(.semibold)
                        IconPickerView(selectedIcon: $viewModel.icon)
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.gray, lineWidth: 0.5)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Desired duration")
                                    .fontWeight(.semibold)
                                
                                if isPartOfChallenge {
                                    Text("This habit is currently part of a challenge, so you can’t change its duration right now.")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Picker("Duration", selection: $viewModel.duration) {
                                ForEach(HabitDuration.allCases) { option in
                                    Text(option.displayName)
                                        .tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                            .disabled(isPartOfChallenge)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Enable Reminder", isOn: $viewModel.hasReminder)
                            .onChange(of: viewModel.hasReminder) { _, newValue in
                                if newValue {
                                    requestNotificationPermission()
                                }
                            }
                        
                        DatePicker("Reminder Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                            .opacity(viewModel.hasReminder ? 1 : 0.3)
                            .disabled(!viewModel.hasReminder)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.hasReminder)
                    }
                }
            
            SubmitButton(title: "Save", color: viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : .accentColor) {
                saveButtonPressed = true
                saveHabit()
                if mode == .adding {
                    dismiss()
                } else {
                    showEditSheet = false
                }
            }
        }
        .padding()
        .padding(.horizontal)
    }
    
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Permission error: \(error)")
            } else {
                print("Permission granted: \(granted)")
            }
        }
    }


    private func syncWithServerBeforeQuitting() {
        if !deleteButtonPressed && !saveButtonPressed && !viewModel.name.isEmpty {
            saveHabit()
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

    private func saveHabit() {
        Task {
            switch mode {
            case .adding:
                await addHabit()
            case .editing:
                await editHabit()
            }
        }
    }
    
    private func editHabit() async {
        guard let habit = habit else { return }
        let result = await viewModel.updateHabit(with: habit.id)
        await MainActor.run {
            habit.name = viewModel.name
            habit.habitDescription = viewModel.description
            habit.icon = viewModel.icon
            habit.duration = viewModel.duration
            habit.reminderTime = viewModel.hasReminder ? viewModel.reminderTime : nil
            habit.updatedAt = .now
            try? context.save()
        }
        print("SAVING CHANGES FOR HABIT WITH NAME: \(habit.name)")
        if userManager.profile.isSignedInToServer {
            Helpers.handleResult(result) { codableHabit in
                print("✅ Updated the habit on the server with habit name: '\(codableHabit.name)' and id: '\(codableHabit.id)'")
            } onFailure: { error in
                print("❌ Error: Failed to update the habit on the server: \(error.localizedDescription)")
            }
        }
    }
    
    private func addHabit() async {
        let habitID = UUID()
        await MainActor.run {
            let habit = Habit(
                id: habitID,
                user: LightweightUser(id: userManager.profile.id),
                name: viewModel.name,
                description: viewModel.description,
                icon: viewModel.icon,
                duration: viewModel.duration,
                reminderTime: viewModel.hasReminder ? viewModel.reminderTime : nil,
                createdAt: .now,
                updatedAt: .now
            )
            context.insert(habit)
        }
        if userManager.profile.isSignedInToServer {
            let result = await viewModel.createHabit(with: habitID)
            Helpers.handleResult(result) { codableHabit in
                print("✅ Saved the habit on the server with habit name: '\(codableHabit.name)' and id: '\(codableHabit.id)'")
            } onFailure: { error in
                print("❌ Error: Failed to save new habit on the server: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleHabitNotification(habitName: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time for your habit: \(habitName)"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let identifier = "habit_\(habitName)_\(hour)_\(minute)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule: \(error)")
            } else {
                print("Notification scheduled for \(habitName) at \(hour):\(minute)")
            }
        }
    }
}

#Preview {
    HabitDetailView()
}

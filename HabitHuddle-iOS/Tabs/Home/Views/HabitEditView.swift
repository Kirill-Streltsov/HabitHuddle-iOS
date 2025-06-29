//
//  HabitEditView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 28.06.25.
//

import SwiftUI
import SwiftData

struct HabitEditView: View {

    @Query
    var habits: [Habit]
    
    @ObservedObject var viewModel: HabitDetailView.ViewModel
    @State private var saveButtonPressed = false
    @State private var isCheckedIn = false
    @State private var deleteButtonPressed = false
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: LocalUserManager
    
    var isPartOfChallenge: Bool {
        if let habit = viewModel.habit, !habit.challenges.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    init(viewModel: HabitDetailView.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
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
                                        //requestNotificationPermission()
                                    }
                                }
                            
                            DatePicker("Reminder Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                                .opacity(viewModel.hasReminder ? 1 : 0.3)
                                .disabled(!viewModel.hasReminder)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.hasReminder)
                        }
                    }
                
                SubmitButton(title: "Save", color: viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : .accentColor, iconName: nil) {
                    HapticManager.trigger(.success)
                    saveButtonPressed = true
                    Task {
                        if viewModel.habit == nil {
                            await addHabit()
                        } else {
                            await saveChanges()
                        }
                    }
                    dismiss()
                }
                .allowsHitTesting(!viewModel.name.isEmpty)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let icon = viewModel.icon {
                        Image(systemName: icon)
                    }
                }
            }
            .padding()
            .padding(.horizontal)
            .onDisappear {
                if !deleteButtonPressed && !saveButtonPressed && !viewModel.name.isEmpty {
                    Task {
                        if let habit = viewModel.habit, habits.contains(where: { $0.id == habit.id }) {
                            await saveChanges()
                        }
                    }
                }
            }
        }
    }
    
    private func saveChanges() async {
        guard let habit = viewModel.habit else { return }
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
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Permission error: \(error)")
            } else {
                print("Permission granted: \(granted)")
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
    HabitEditView(viewModel: HabitDetailView.ViewModel())
}

//
//  HabitEditView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 28.06.25.
//

import SwiftUI
import SwiftData
import UserNotifications

struct HabitEditView: View {

    @Query
    var habits: [Habit]
    
    @State private var categories = [String]()
    
    @ObservedObject var viewModel: HabitDetailView.ViewModel
    @State private var isCheckedIn = false
    @State private var notificationsAllowed = false
    @State private var notificationsDisabled = false
    @State private var wasSyncedAtTheBeginning = false
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var appState: AppState
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
                    VStack(spacing: 32) {
                        textFieldsView
                        iconPickerView
                        categoryView
                        durationView
                        privacyView
                        remindersView
                    }
                
                SubmitButton(title: "Save", color: viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : .accentColor, iconName: nil) {
                    HapticManager.trigger(.success)
                    Task {
                        guard let habit = viewModel.habit else {
                            await addHabit()
                            return
                        }
                        await saveChanges()
                        if !viewModel.isSynced {
                            let _ = await viewModel.deleteHabit(with: habit.id)
                        }
                        if !wasSyncedAtTheBeginning && viewModel.isSynced {
                            await addHabitToTheServer(with: habit.id)
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
            .onAppear {
                wasSyncedAtTheBeginning = viewModel.isSynced
                fillCategories()
                Task {
                    await checkNotifications()
                }
            }
            .onChange(of: viewModel.isSynced) { _, newValue in
                if !newValue {
                    viewModel.isPublic = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await checkNotifications()
                }
            }
        }
    }
    
    private func fillCategories() {
        categories = [
            "Health",
            "Productivity",
            "Mindfulness",
            "Learning",
            "Fitness"
        ]
        for habit in habits {
            if !habit.category.isEmpty {
                if !categories.contains(habit.category) {
                    categories.append(habit.category)
                }
            }
        }
    }
    
    private var textFieldsView: some View {
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
    }
    
    private var iconPickerView: some View {
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
    }
    
    private var categoryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Category")
                    .fontWeight(.semibold)
                InfoView(text: "Categories help you organize your habits into meaningful groups")
            }
            
            if !categories.isEmpty {
                Menu {
                    ForEach(categories, id: \.self) { category in
                        Button("\(category)") {
                            viewModel.category = category
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Select an existing category")
                            .foregroundColor(.accentColor)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
                        
            CustomStyledTextField(placeholder: categories.count == 0 ? "Add a new one..." : "Or add a new one...", text: $viewModel.category)
        }
    }
    
    private var durationView: some View {
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
    }
    
    private var privacyView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Privacy Options")
                    .fontWeight(.semibold)
            }
            HStack {
                Text("Sync with Server")
                InfoView(text: "Turn on to sync habits to our server and access them on all your devices.\n\nYou must be signed in.\n\nTurning off keeps habits only on this device and deletes them from the server.")
                Spacer()
                Toggle("", isOn: $viewModel.isSynced)
                    .labelsHidden()
                    .disabled(!appState.isAuthenticated)
            }
            HStack {
                Text("Open to Friends")
                InfoView(text: "Make a habit “open to friends” to let them see it and challenge you!\n\nOnly synced habits can be shared.")
                Spacer()
                Toggle("", isOn: $viewModel.isPublic)
                    .labelsHidden()
                    .disabled(!viewModel.isSynced || !appState.isAuthenticated)
            }
        }
    }
    
    private var remindersView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if notificationsDisabled {
                VStack(alignment: .leading, spacing: 8) {
                            (
                                Text("To receive reminders, enable notifications in ")
                                +
                                Text("Settings")
                                    .foregroundColor(.blue)
                                    .underline()
                                    
                            )
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .onTapGesture {
                                openAppSettings()
                            }
                        }
            }
            
            Toggle(isOn: $viewModel.hasReminder) {
                Text("Enable Reminders")
                    .fontWeight(.medium)
            }
                .disabled(notificationsDisabled)
                .opacity(notificationsDisabled ? 0.5 : 1)
                .onChange(of: viewModel.hasReminder) { _, newValue in
                    if newValue {
                        requestNotificationPermission()
                    }
                }
            
            DatePicker(selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute) {
                Text("Reminder Time")
                    .fontWeight(.medium)
            }
                .opacity(viewModel.hasReminder ? 1 : 0.5)
                .disabled(!viewModel.hasReminder)
                .animation(.easeInOut(duration: 0.3), value: viewModel.hasReminder)
        }
    }
    
    // MARK: Saving/Updating functionality
    
    private func saveChanges() async {
        guard let habit = viewModel.habit else { return }
        await MainActor.run {
            habit.name = viewModel.name
            habit.habitDescription = viewModel.description
            habit.isSyncable = viewModel.isSynced
            habit.isPublic = viewModel.isPublic
            habit.category = viewModel.category
            habit.icon = viewModel.icon
            habit.duration = viewModel.duration
            habit.reminderTime = viewModel.hasReminder ? viewModel.reminderTime : nil
            habit.updatedAt = .now
            try? context.save()
            setNotificationBehaviour(for: habit)
            if viewModel.isSynced {
                Task {
                    await saveChangesOnTheServer(for: habit)
                }
            }
        }
    }
    
    private func saveChangesOnTheServer(for habit: Habit) async {
        if userManager.profile.isSignedInToServer && viewModel.isSynced {
            let result = await viewModel.updateHabit(with: habit.id)
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
                isPublic: viewModel.isPublic,
                isSyncable: viewModel.isSynced,
                category: viewModel.category,
                icon: viewModel.icon,
                duration: viewModel.duration,
                reminderTime: viewModel.hasReminder ? viewModel.reminderTime : nil,
                createdAt: .now,
                updatedAt: .now
            )
            context.insert(habit)
            setNotificationBehaviour(for: habit)
            if viewModel.isSynced {
                Task {
                    await addHabitToTheServer(with: habitID)
                }
            }
        }
    }
    
    private func addHabitToTheServer(with habitID: UUID) async {
        if userManager.profile.isSignedInToServer {
            let result = await viewModel.createHabit(with: habitID)
            Helpers.handleResult(result) { codableHabit in
                print("✅ Saved the habit on the server with habit name: '\(codableHabit.name)' and id: '\(codableHabit.id)'")
            } onFailure: { error in
                print("❌ Error: Failed to save new habit on the server: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Notification functionality
    
    private func areNotificationsAllowed() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }
    
    private func areNotificationsDisabled() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .denied
    }
    
    private func checkNotifications() async {
        Task {
            notificationsAllowed = await areNotificationsAllowed()
            notificationsDisabled = await areNotificationsDisabled()
        }
    }
    
    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
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
    
    private func setNotificationBehaviour(for habit: Habit) {
        if habit.reminderTime != nil {
            scheduleHabitNotification(for: habit)
        } else {
            cancelHabitNotification(for: habit)
        }
    }
    
    private func scheduleHabitNotification(for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time for your habit: \(habit.name)"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = habit.reminderTime?.hour
        dateComponents.minute = habit.reminderTime?.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let identifier = "habit_\(habit.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule: \(error)")
            } else {
                print("Notification scheduled for \(habit.name) at \(String(describing: habit.reminderTime?.hour)):\(String(describing: habit.reminderTime?.minute))")
            }
        }
    }
    
    func cancelHabitNotification(for habit: Habit) {
        let identifier = "habit_\(habit.id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notification cancelled for \(habit.name)")
    }
}

#Preview {
    HabitEditView(viewModel: HabitDetailView.ViewModel())
}

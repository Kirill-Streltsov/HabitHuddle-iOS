//
//  HabitEditView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 28.06.25.
//

import SwiftUI
import SwiftData
@preconcurrency import UserNotifications

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
    
    @AppStorage("deviceToken") private var deviceToken: String = ""
    @AppStorage("hasSentDeviceToken") private var hasSentDeviceToken = false
    
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
                
                SubmitButton(title: .save, color: viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : .accentColor, iconName: nil) {
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
                if appState.isAuthenticated && viewModel.habit == nil {
                    viewModel.isSynced = true
                }
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
            .onDisappear {
                Task {
                    await checkNotifications()
                }
            }
        }
    }
    
    private func fillCategories() {
        categories = [
            String(localized: .health),
            String(localized: .productivity),
            String(localized: .mindfulness),
            String(localized: .learning),
            String(localized: .fitness)
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
                placeholder: String(localized: .habitName),
                text: $viewModel.name
            )

            CustomStyledTextField(
                placeholder: String(localized: .descriptionOptional),
                text: $viewModel.description
            )
        }
    }
    
    private var iconPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.chooseAnIcon)
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
                Text(.category)
                    .fontWeight(.semibold)
                InfoView(text: .categoriesHelpYouOrganizeYourHabitsIntoMeaningfulGroups)
            }
            
            if !categories.isEmpty {
                Menu {
                    ForEach(categories, id: \.self) { category in
                        Button(LocalizedStringKey(category)) {
                            viewModel.category = category
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text(.selectAnExistingCategory)
                            .foregroundColor(.accentColor)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
                        
            CustomStyledTextField(placeholder: categories.count == 0 ? String(localized: .addANewOne) : String(localized: .orAddANewOne), text: $viewModel.category)
        }
    }
    
    private var durationView: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(.desiredDuration)
                        .fontWeight(.semibold)
                    
                    if isPartOfChallenge {
                        Text(.thisHabitIsCurrentlyPartOfAChallengeSoYouCantChangeItsDurationRightNow)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                
                Picker(String(localized: .duration), selection: $viewModel.duration) {
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
                Text(.privacyOptions)
                    .fontWeight(.semibold)
            }
            HStack {
                Text(.syncWithServer)
                InfoView(text: .turnOnToSyncHabitsWithOurServerAndAccessThemOnAllYourDevicesYouMustBeSignedInTurningOffKeepsHabitsOnlyOnThisDeviceAndDeletesThemFromTheServer)
                Spacer()
                Toggle("", isOn: $viewModel.isSynced)
                    .labelsHidden()
                    .disabled(!appState.isAuthenticated)
            }
            HStack {
                Text(.openToFriends)
                InfoView(text: .makeAHabitOpenToFriendsToLetThemSeeItAndChallengeYouOnlySyncedHabitsCanBeShared)
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
                                Text(.toReceiveRemindersEnableNotificationsIn)
                                +
                                Text(.settings)
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
                Text(.enableReminders)
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
                Text(.reminderTime)
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
            context.saveOrLog()
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
    
    private func checkNotifications() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .authorized {
            DispatchQueue.main.async {
                print("DEVICE TOKEN: \(deviceToken)")
                UIApplication.shared.registerForRemoteNotifications()
                if appState.isAuthenticated && !hasSentDeviceToken {
                    Task {
                        await viewModel.updateUser(user: userManager.profile)
                    }
                }
            }
        }
        Task {
            notificationsAllowed = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            notificationsDisabled = settings.authorizationStatus == .denied
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
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("Permission granted: \(granted)")
            }
        }
    }
    
    private func setNotificationBehaviour(for habit: Habit) {
        if habit.reminderTime != nil {
            scheduleHabitNotification(for: habit)
        } else {
            habit.cancelHabitNotification()
        }
    }
    
    private func scheduleHabitNotification(for habit: Habit) {
        let content = UNMutableNotificationContent()
        let notification = NotificationGenerator.randomNotification(for: habit.name)
        content.title = notification.title
        content.subtitle = notification.subtitle
        content.body = notification.body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = habit.reminderTime?.hour
        dateComponents.minute = habit.reminderTime?.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let identifier = "habit_\(habit.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let habitName = habit.name
        let hour = habit.reminderTime?.hour
        let minute = habit.reminderTime?.minute

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule: \(error)")
            } else {
                print("Notification scheduled for \(habitName) at \(String(describing: hour)):\(String(describing: minute))")
            }
        }
    }
}

#Preview {
    HabitEditView(viewModel: HabitDetailView.ViewModel())
}

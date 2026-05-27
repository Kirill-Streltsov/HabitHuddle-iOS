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
            VStack(spacing: 24) {
                nameSection
                iconSection
                categorySection
                durationSection
                privacySection
                remindersSection
            }
            .padding(.vertical, 16)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let icon = viewModel.icon {
                        Image(systemName: icon)
                    }
                }
                if viewModel.habit == nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            HapticManager.trigger(.success)
                            Task { await addHabit() }
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                        }
                        .tint(.blue)
                        .disabled(viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .onAppear {
                wasSyncedAtTheBeginning = viewModel.isSynced
                if appState.isAuthenticated && viewModel.habit == nil {
                    viewModel.isSynced = true
                }
                fillCategories()
                Task { await checkNotifications() }
            }
            .onChange(of: viewModel.isSynced) { _, newValue in
                if !newValue { viewModel.isPublic = false }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task { await checkNotifications() }
            }
            .onDisappear {
                Task {
                    await checkNotifications()
                    guard let habit = viewModel.habit else { return }
                    await saveChanges()
                    if !viewModel.isSynced {
                        let _ = await viewModel.deleteHabit(with: habit.id)
                    }
                    if !wasSyncedAtTheBeginning && viewModel.isSynced {
                        await addHabitToTheServer(with: habit.id)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Sections

    private var nameSection: some View {
        formCard {
            fieldRow(icon: "character.cursor.ibeam", color: .blue) {
                TextField(String(localized: .habitName), text: $viewModel.name)
            }
            cardDivider
            fieldRow(icon: "text.alignleft", color: .gray) {
                TextField(String(localized: .descriptionOptional), text: $viewModel.description)
            }
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader(.chooseAnIcon)
            formCard {
                IconPickerView(selectedIcon: $viewModel.icon)
                    .frame(maxHeight: 300)
                    .padding(8)
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(.category)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.leading, 20)
                InfoView(text: .categoriesHelpYouOrganizeYourHabitsIntoMeaningfulGroups)
                Spacer()
            }
            formCard {
                if !categories.isEmpty {
                    fieldRow(icon: "list.bullet", color: .purple) {
                        Menu {
                            ForEach(categories, id: \.self) { category in
                                Button(LocalizedStringKey(category)) {
                                    viewModel.category = category
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.category.isEmpty ? String(localized: .selectAnExistingCategory) : viewModel.category)
                                    .foregroundStyle(viewModel.category.isEmpty ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    cardDivider
                }
                fieldRow(icon: "plus", color: .green) {
                    TextField(
                        categories.isEmpty ? String(localized: .addANewOne) : String(localized: .orAddANewOne),
                        text: $viewModel.category
                    )
                }
            }
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                sectionHeader(.desiredDuration)
                if isPartOfChallenge {
                    Text(.thisHabitIsCurrentlyPartOfAChallengeSoYouCantChangeItsDurationRightNow)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            formCard {
                Picker(String(localized: .duration), selection: $viewModel.duration) {
                    ForEach(HabitDuration.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(12)
                .disabled(isPartOfChallenge)
            }
        }
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader(.privacyOptions)
            formCard {
                toggleRow(
                    icon: "arrow.triangle.2.circlepath",
                    color: .green,
                    title: Text(.syncWithServer),
                    info: .turnOnToSyncHabitsWithOurServerAndAccessThemOnAllYourDevicesYouMustBeSignedInTurningOffKeepsHabitsOnlyOnThisDeviceAndDeletesThemFromTheServer,
                    isOn: $viewModel.isSynced,
                    disabled: !appState.isAuthenticated
                )
                cardDivider
                toggleRow(
                    icon: "person.2.fill",
                    color: .blue,
                    title: Text(.openToFriends),
                    info: .makeAHabitOpenToFriendsToLetThemSeeItAndChallengeYouOnlySyncedHabitsCanBeShared,
                    isOn: $viewModel.isPublic,
                    disabled: !viewModel.isSynced || !appState.isAuthenticated
                )
            }
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader(.enableReminders)
            if notificationsDisabled {
                (
                    Text(.toReceiveRemindersEnableNotificationsIn)
                    + Text(.settings).foregroundColor(.blue).underline()
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
                .onTapGesture { openAppSettings() }
            }
            formCard {
                toggleRow(
                    icon: "bell.fill",
                    color: .orange,
                    title: Text(.enableReminders),
                    info: nil,
                    isOn: $viewModel.hasReminder,
                    disabled: notificationsDisabled
                )
                .opacity(notificationsDisabled ? 0.5 : 1)
                cardDivider
                HStack(spacing: 12) {
                    settingsIcon("clock.fill", color: .purple)
                    DatePicker(
                        selection: $viewModel.reminderTime,
                        displayedComponents: .hourAndMinute
                    ) {
                        Text(.reminderTime).foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .opacity(viewModel.hasReminder ? 1 : 0.4)
                .disabled(!viewModel.hasReminder)
                .animation(.easeInOut(duration: 0.2), value: viewModel.hasReminder)
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal)
    }

    @ViewBuilder
    private func fieldRow<Content: View>(icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            settingsIcon(icon, color: color)
            content()
        }
        .frame(minHeight: 44)
        .padding(.vertical, 2)
        .padding(.horizontal, 12)
        .padding(.trailing, 4)
    }

    @ViewBuilder
    private func toggleRow(icon: String, color: Color, title: some View, info: LocalizedStringResource?, isOn: Binding<Bool>, disabled: Bool) -> some View {
        HStack(spacing: 12) {
            settingsIcon(icon, color: color)
            title
            if let info {
                InfoView(text: info)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .disabled(disabled)
        }
        .frame(minHeight: 44)
        .padding(.vertical, 2)
        .padding(.horizontal, 12)
    }

    private func settingsIcon(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .medium))
            .frame(width: 28, height: 28)
            .foregroundStyle(.white)
            .background(color.gradient)
            .clipShape(.rect(cornerRadius: 7))
    }

    private var cardDivider: some View {
        Divider().padding(.leading, 52)
    }

    private func sectionHeader(_ key: LocalizedStringResource) -> some View {
        Text(key)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
    }

    // MARK: - Data

    private func fillCategories() {
        categories = [
            String(localized: .health),
            String(localized: .productivity),
            String(localized: .mindfulness),
            String(localized: .learning),
            String(localized: .fitness)
        ]
        for habit in habits {
            if !habit.category.isEmpty && !categories.contains(habit.category) {
                categories.append(habit.category)
            }
        }
    }

    // MARK: - Saving/Updating

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
                Task { await saveChangesOnTheServer(for: habit) }
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
                Task { await addHabitToTheServer(with: habitID) }
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

    // MARK: - Notifications

    private func checkNotifications() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .authorized {
            DispatchQueue.main.async {
                print("DEVICE TOKEN: \(deviceToken)")
                UIApplication.shared.registerForRemoteNotifications()
                if appState.isAuthenticated && !hasSentDeviceToken {
                    Task { await viewModel.updateUser(user: userManager.profile) }
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

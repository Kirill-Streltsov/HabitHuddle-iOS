//
//  HabitDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftData
import SwiftUI

struct HabitDetailView: View {
    enum Mode {
        case editing
        case adding
    }

    var habit: Habit?
    let mode: Mode

    @State private var isCheckedIn = false
    @State private var challengeButtonPressed = false
    @State private var saveButtonPressed = false
    @State private var deleteButtonPressed = false
    
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
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mode == .adding ? "Create a new habit" : "Update your habit")
                            .font(.largeTitle.weight(.semibold))
                        if mode == .adding {
                            Text("Stay consistent by tracking what matters.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    .padding(.horizontal)
                    if mode == .editing {
                        if let habit = habit {
                            CheckInCardView(habit: habit) {
                                checkIntoHabit(habit)
                            }
                        }
                    }

                    CardView {
                        VStack(spacing: 24) {
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
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Start date:")
                                        .fontWeight(.semibold)

                                    HStack {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundStyle(.secondary)
                                        Text(mode == .adding ? Date.now.longFormatted : habit!.createdAt.fullFormatted)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Desired duration")
                                        .fontWeight(.semibold)

                                    Picker("Duration", selection: $viewModel.duration) {
                                        ForEach(HabitDuration.allCases) { option in
                                            Text(option.displayName)
                                                .tag(option)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle("Enable Reminder", isOn: $viewModel.hasReminder.animation())

                                if viewModel.hasReminder {
                                    DatePicker("Reminder Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                                        .transition(.opacity.combined(with: .slide))
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 8) {
                        SubmitButton(title: "Challenge a friend!", color: viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : .orange) {
                            challengeButtonPressed = true
                        }
                        SubmitButton(title: "Save", color: viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : .accentColor) {
                            saveButtonPressed = true
                            saveHabit()
                            dismiss()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .sheet(isPresented: $challengeButtonPressed) {
                MyFriendsListView(isInFriendsTab: false, habit: habit)
                    .presentationDetents([.medium])
            }
            .toolbar {
                if mode == .editing {
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
    }

    private func syncWithServerBeforeQuitting() {
        if !deleteButtonPressed && !saveButtonPressed && !viewModel.name.isEmpty {
            saveHabit()
        }
    }

    private func populateFields(with habit: Habit) {
        viewModel.name = habit.name
        viewModel.description = habit.habitDescription
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
                    print("❌ Error while posting the check in: \(error)")
                }
            }
        }
    }

    private func deleteHabit() async {
        guard let habit = habit else { return }
        await MainActor.run {
            context.delete(habit)
        }
        Task {
            if userManager.profile.isSignedInToServer {
                let result = await viewModel.deleteHabit(with: habit.id)
                Helpers.handleResult(result) { codableHabit in
                    print("✅ Deleted the habit on the server with habit name: '\(codableHabit.name)' and id: '\(codableHabit.id)'")
                } onFailure: { error in
                    print("❌ Failed to delete the habit on the server: \(error.localizedDescription)")
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
                print("❌ Failed to update the habit on the server: \(error.localizedDescription)")
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
                print("❌ Failed to save new habit on the server: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    HabitDetailView()
}

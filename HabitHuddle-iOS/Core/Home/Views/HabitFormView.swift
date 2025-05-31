//
//  NewHabitView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftUI
import SwiftData

struct HabitFormView: View {
    
    enum Mode {
        case editing
        case adding
    }
    
    var habit: Habit?
    let mode: Mode
    
    @State private var isCheckedIn = false
    @State private var birthDate = Date.now
    @State private var saveButtonPressed = false
    @State private var deleteButtonPressed = false
    @StateObject private var viewModel: ViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    init(habit: Habit? = nil) {
        _viewModel = StateObject(wrappedValue: ViewModel())
        self.habit = habit
        mode = habit == nil ? .adding : .editing
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    if mode == .editing {
                        if let habit = habit {
                            CheckInCardView(habit: habit) {
                                checkIntoHabit(habit)
                            }
                            
                        }
                    }
                    
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mode == .adding ? "Create a new habit" : "Update your habit")
                            .font(.largeTitle.weight(.semibold))
                        if mode == .adding {
                            Text("Stay consistent by tracking what matters.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Input Card
                    InputFormView {
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
                    
                    InputFormView {
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
                        
                    }
                    
                    // MARK: - Reminder
                    InputFormView {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Enable Reminder", isOn: $viewModel.hasReminder.animation())
                            
                            if viewModel.hasReminder {
                                DatePicker("Reminder Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                                    .transition(.opacity.combined(with: .slide))
                            }
                        }
                    }
                    
                    // MARK: - Submit
                    Button {
                        saveButtonPressed = true
                        saveHabit()
                        dismiss()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                    }
                    .disabled(viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                }
                .padding(.top)
            }
            .toolbar {
                if mode == .editing {
                    Button {
                        deleteButtonPressed = true
                        deleteHabit()
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
                }
            }
            .onChange(of: viewModel.duration) { oldValue, newValue in
                if let habit = habit {
                    habit.duration = newValue
                    try? context.save()
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
            let result = await viewModel.checkIntoHabit(with: habit.id)
            handleResult(result) { checkedIn in
                print("THE USER HAS CHECKED IN: \(checkedIn)")
            } onFailure: { error in
                print("ERROR WHILE POSTING THE CHECK IN: \(error)")
            }
        }
    }
    
    private func deleteHabit() {
        Task {
            guard let habit = habit else { return }
            let result = await viewModel.deleteHabit(with: habit.id)
            context.delete(habit)
            handleResult(result) { codableHabit in
                print("✅ Deleted the habit on the server with habit name: '\(codableHabit.name)' and id: '\(codableHabit.id)'")
            } onFailure: { error in
                print("❌ Failed to delete the habit on the server: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveHabit() {
        Task {
            switch mode {
            case .adding:
                guard let user = try? context.fetch(FetchDescriptor<User>()).first else { return }
                let habitID = UUID()
                let habit = Habit(
                    id: habitID,
                    user: LightweightUser(id: user.id),
                    name: viewModel.name,
                    description: viewModel.description,
                    duration: viewModel.duration,
                    reminderTime: viewModel.reminderTime,
                    createdAt: .now,
                    updatedAt: .now
                )
                context.insert(habit)
                let result = await viewModel.createHabit(with: habitID)
                handleResult(result) { codableHabit in
                    print("✅ Saved the habit on the server with habit name: '\(codableHabit.name)' and id: '\(codableHabit.id)'")
                } onFailure: { error in
                    print("❌ Failed to save new habit on the server: \(error.localizedDescription)")
                }
            case .editing:
                guard let habit = habit else { return }
                let result = await viewModel.updateHabit(with: habit.id)
                habit.name = viewModel.name
                habit.habitDescription = viewModel.description
                habit.duration = viewModel.duration
                habit.reminderTime = viewModel.reminderTime
                habit.updatedAt = .now
                try? context.save()
                print("SAVING CHANGES FOR HABIT WITH NAME: \(habit.name)")
                handleResult(result) { codableHabit in
                    print("✅ Updated the habit on the server with habit name: '\(codableHabit.name)' and id: '\(codableHabit.id)'")
                } onFailure: { error in
                    print("❌ Failed to update the habit on the server: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    HabitFormView()
}

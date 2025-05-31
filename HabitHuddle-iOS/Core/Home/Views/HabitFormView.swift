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
                        Text(mode == .adding ? "Create a New Habit" : "Update your habit")
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
                    Button(action: saveHabit) {
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
            let result = await viewModel.checkIntoHabit(habitID: habit.id)
            handleResult(result) { checkedIn in
                print("THE USER HAS CHECKED IN: \(checkedIn)")
            } onFailure: { error in
                print("ERROR WHILE POSTING THE CHECK IN: \(error)")
            }
        }
    }
    
    private func saveHabit() {
        Task {
            switch mode {
            case .adding:
                let result = await viewModel.createHabit()
                handleResult(result) { codableHabit in
                    let habit = Habit(
                        id: codableHabit.id,
                        user: codableHabit.user,
                        name: codableHabit.name,
                        description: codableHabit.description,
                        duration: codableHabit.duration,
                        reminderTime: codableHabit.reminderTime,
                        createdAt: .now,
                        updatedAt: .now
                    )
                    context.insert(habit)
                    dismiss()
                } onFailure: { error in
                    print("❌ Failed to save new habit on the server: \(error.localizedDescription)")
                }
            case .editing:
                guard let habitID = habit?.id else { return }
                let result = await viewModel.updateHabit(habitID: habitID)
                handleResult(result) { codableHabit in
                    habit?.name = codableHabit.name
                    habit?.habitDescription = codableHabit.description
                    habit?.duration = codableHabit.duration
                    habit?.reminderTime = codableHabit.reminderTime
                    habit?.updatedAt = .now
                    
                    do {
                        try context.save()
                        dismiss()
                    } catch {
                        print("❌ Failed to save an already existing habit locally: \(error.localizedDescription)")
                    }
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

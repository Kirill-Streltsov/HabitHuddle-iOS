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
    @StateObject private var viewModel: ViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    init(habit: Habit? = nil) {
        _viewModel = StateObject(wrappedValue: ViewModel())
        self.habit = habit
        mode = habit == nil ? .adding : .editing
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(mode == .adding ? "Create a New Habit" : "Update your habit")
                        .font(.largeTitle.weight(.semibold))
                    Text("Stay consistent by tracking what matters.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
                
                // MARK: - Frequency Card
                InputFormView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Frequency")
                            .font(.subheadline)
                        
                        Picker("Frequency", selection: $viewModel.frequency) {
                            ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue.capitalized)
                                    .tag(frequency)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                // MARK: - Reminder Card
                InputFormView {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Enable Reminder", isOn: $viewModel.hasReminder.animation())
                        
                        if viewModel.hasReminder {
                            DatePicker("Reminder Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                                .transition(.opacity.combined(with: .slide))
                        }
                    }
                }
                
                // MARK: - Submit Button
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
            }
        }
    }
    
    private func populateFields(with habit: Habit) {
        
        viewModel.name = habit.name
        viewModel.description = habit.habitDescription
        viewModel.frequency = habit.frequency
        if let reminderTime = habit.reminderTime {
            viewModel.reminderTime = reminderTime
            viewModel.hasReminder = true
        } else {
            viewModel.hasReminder = false
        }
    }
    
    private func saveHabit() {
        switch mode {
        case .adding:
            Task {
                let result = await viewModel.createHabit()
                handleResult(result) { codableHabit in
                    let habit = Habit(
                        id: codableHabit.id,
                        user: codableHabit.user,
                        name: codableHabit.name,
                        description: codableHabit.description,
                        frequency: codableHabit.frequency,
                        reminderTime: codableHabit.reminderTime
                    )
                    context.insert(habit)
                    dismiss()
                } onFailure: { error in
                    print("❌ Failed to save new habit: \(error.localizedDescription)")
                }
            }
        case .editing:
            Task {
                guard let habitID = habit?.id else { return }
                let result = await viewModel.updateHabit(habitID: habitID)
                handleResult(result) { codableHabit in
                    habit?.name = codableHabit.name
                    habit?.habitDescription = codableHabit.description
                    habit?.frequency = codableHabit.frequency
                    habit?.reminderTime = codableHabit.reminderTime
                }
                do {
                    try context.save()
                    dismiss()
                } catch {
                    print("❌ Failed to save an already existing habit: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    HabitFormView()
}

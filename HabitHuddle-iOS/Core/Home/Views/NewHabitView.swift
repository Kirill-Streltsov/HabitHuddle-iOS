//
//  NewHabitView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftUI
import SwiftData

struct NewHabitView: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: ViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create a New Habit")
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
                        Text("Save Habit")
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
        }
    }

    private func saveHabit() {
        Task {
            let result = await viewModel.sendHabit()
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
                print("❌ Failed to save habit: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NewHabitView(appState: AppState())
}

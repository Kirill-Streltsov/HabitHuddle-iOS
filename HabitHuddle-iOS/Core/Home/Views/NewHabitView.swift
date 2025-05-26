//
//  NewHabitView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftUI
import SwiftData

struct NewHabitView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.modelContext) private var context

    
    @Query var habits: [Habit]
    
    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: ViewModel(appState: appState))
    }
    
    var body: some View {
        
        UserDataView { user in
            VStack {
                TextField("Name", text: $viewModel.name)
                TextField("Description", text: $viewModel.description)
                Picker("Label", selection: $viewModel.frequency) {
                    ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                        Text("\(frequency)")
                    }
                }
                .pickerStyle(.segmented)
                Button {
                    Task {
                        let result = await viewModel.sendHabit()
                        handleResult(result) { codableHabit in
                            let habit = Habit(
                                id: codableHabit.id,
                                user: codableHabit.user,
                                name: codableHabit.name,
                                description: codableHabit.description,
                                frequency: codableHabit.frequency
                            )
                            context.insert(habit)
                        } onFailure: { error in
                            print("❌ Failed to save habit: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Text("Save habit")
                }
            }
        }
        
    }
}

#Preview {
    NewHabitView(appState: AppState())
}

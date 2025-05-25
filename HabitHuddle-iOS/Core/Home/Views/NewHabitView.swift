//
//  NewHabitView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftUI
import SwiftData

struct NewHabitView: View {
    
    @Query var users: [User]
    var user: User? { users.first }
    
    @StateObject var viewModel: ViewModel

    
    @Query var habits: [Habit]
    
    init() {
        _viewModel = StateObject(wrappedValue: ViewModel())
    }
    
    var body: some View {
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
                    await viewModel.sendHabit()
                }
            } label: {
                Text("Save habit")
            }
        }
    }
}

#Preview {
    NewHabitView()
}

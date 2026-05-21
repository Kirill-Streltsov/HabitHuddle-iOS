//
//  HabitsGridView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.25.
//

import SwiftUI

struct HabitsGridView: View {
    let habits: [Habit]

    enum SortMode: String, CaseIterable {
        case alphabetical = "Alphabetical"
        case createdAt = "Newest First"
        case byGroup = "Grouped"

        var localizedName: LocalizedStringResource {
            switch self {
            case .alphabetical: .alphabetical
            case .createdAt: .newestFirst
            case .byGroup: .grouped
            }
        }
    }

    @State private var sortMode: SortMode = .byGroup

    private var sortedHabits: [Habit] {
        switch sortMode {
        case .alphabetical:
            return habits.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .createdAt:
            return habits.sorted { $0.createdAt > $1.createdAt }
        case .byGroup:
            return habits
        }
    }

    // Group habits with non-empty categories
    var groupedHabits: [String: [Habit]] {
        Dictionary(
            grouping: sortedHabits.filter { !$0.category.isEmpty },
            by: { $0.category }
        )
    }

    // Habits with empty category string
    var ungroupedHabits: [Habit] {
        sortedHabits.filter { $0.category.isEmpty }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                if sortMode != .byGroup {
                    noCategoriesHabits
                } else {
                    if groupedHabits.isEmpty {
                        noCategoriesHabits
                    } else {
                        groupedByCategoriesHabits
                        otherHabits
                    }
                }
            }
            .padding(.top)
            .padding(.bottom)
        }
        .toolbar {
            if !habits.isEmpty {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(SortMode.allCases, id: \.self) { mode in
                            Button {
                                withAnimation {
                                    sortMode = mode
                                }
                            } label: {
                                Label(String(localized: mode.localizedName), systemImage: sortMode == mode ? "checkmark.circle" : "circle")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(.blue)
                            .font(.title2)
                    }
                }
            }
        }
    }

    private var noCategoriesHabits: some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
            ForEach(sortedHabits) { habit in
                NavigationLink(value: habit) {
                    HabitCard(habit: habit)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private var groupedByCategoriesHabits: some View {
        ForEach(groupedHabits.keys.sorted(), id: \.self) { category in
            if let habitsForCategory = groupedHabits[category], !habitsForCategory.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey(category))
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(habitsForCategory) { habit in
                            NavigationLink(value: habit) {
                                HabitCard(habit: habit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var otherHabits: some View {
        Group {
            if !ungroupedHabits.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(.otherHabits)
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(ungroupedHabits) { habit in
                            NavigationLink(value: habit) {
                                HabitCard(habit: habit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    HabitsGridView(habits: Habit.createTestHabitsWithCheckIns())
}
#endif

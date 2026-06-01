//
//  ManageCategoriesView.swift
//  HabitHuddle-iOS
//

import SwiftUI
import SwiftData

struct ManageCategoriesView: View {

    @Query private var habits: [Habit]

    @StateObject private var viewModel = ManageCategoriesViewModel()

    private var categories: [ManageCategoriesViewModel.CategorySummary] {
        viewModel.summaries(for: habits, including: Habit.defaultCategorySuggestions)
    }

    var body: some View {
        List {
            Section {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryDetailView(categoryName: category.name)) {
                        row(for: category)
                    }
                }
            } footer: {
                Text(.tapACategoryToSeeAndManageTheHabitsInIt)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(String(localized: .manageCategories))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(for category: ManageCategoriesViewModel.CategorySummary) -> some View {
        HStack(spacing: 12) {
            rowIcon("tag.fill", color: .purple)
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(category.name))
                    .foregroundStyle(.primary)
                countLabel(category.habitCount)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func countLabel(_ count: Int) -> some View {
        if count == 0 {
            Text(.noHabitsYet)
        } else {
            Text(.usedByHabits(count))
        }
    }

    private func rowIcon(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .medium))
            .frame(width: 28, height: 28)
            .foregroundStyle(.white)
            .background(color.gradient)
            .clipShape(.rect(cornerRadius: 7))
    }
}

#Preview {
    NavigationStack {
        ManageCategoriesView()
    }
}

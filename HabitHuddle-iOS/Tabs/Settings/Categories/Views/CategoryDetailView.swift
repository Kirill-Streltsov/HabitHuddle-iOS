//
//  CategoryDetailView.swift
//  HabitHuddle-iOS
//

import SwiftUI
import SwiftData

struct CategoryDetailView: View {

    let categoryName: String

    @Query private var habits: [Habit]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var appState: AppState

    @StateObject private var viewModel = ManageCategoriesViewModel()

    @State private var renameText = ""
    @State private var showRenameAlert = false
    @State private var showDeleteAlert = false

    private var habitsInCategory: [Habit] {
        habits
            .filter { $0.category == categoryName }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        Group {
            if habitsInCategory.isEmpty {
                emptyState
            } else {
                detailList
            }
        }
        .navigationTitle(Text(LocalizedStringKey(categoryName)))
        .navigationBarTitleDisplayMode(.inline)
        .alert(String(localized: .renameCategory), isPresented: $showRenameAlert) {
            TextField(String(localized: .categoryName), text: $renameText)
            Button(String(localized: .save)) { commitRename() }
            Button(String(localized: .cancel), role: .cancel) {}
        } message: {
            Text(.enterANewNameForThisCategory)
        }
        .alert(String(localized: .deleteCategory), isPresented: $showDeleteAlert) {
            Button(String(localized: .delete), role: .destructive) { commitDelete() }
            Button(String(localized: .cancel), role: .cancel) {}
        } message: {
            Text(.thisWontDeleteYourHabitsTheyllJustBecomeUncategorized)
        }
    }

    // MARK: - Content

    private var detailList: some View {
        List {
            Section(header: Text(.habits)) {
                ForEach(habitsInCategory) { habit in
                    habitRow(habit)
                }
            }

            Section {
                Button {
                    beginRename()
                } label: {
                    HStack(spacing: 12) {
                        rowIcon("pencil", color: .blue)
                        Text(.rename).foregroundStyle(.primary)
                    }
                }

                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    HStack(spacing: 12) {
                        rowIcon("trash", color: .red)
                        Text(.deleteCategory)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    private func habitRow(_ habit: Habit) -> some View {
        HStack(spacing: 12) {
            rowIcon(habit.icon ?? "checkmark.seal.fill", color: .accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .foregroundStyle(.primary)
                Text(habit.duration.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text(.noHabitsUseThisCategoryYet)
            } icon: {
                Image(systemName: "tray")
            }
        } description: {
            Text(.chooseThisCategoryForAHabitToGroupItHere)
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

    // MARK: - Actions

    private func beginRename() {
        renameText = categoryName
        showRenameAlert = true
    }

    private func commitRename() {
        let newName = renameText
        Task {
            let didChange = await viewModel.rename(categoryName, to: newName, in: habits, context: context, syncsToServer: appState.isAuthenticated)
            if didChange {
                HapticManager.trigger(.success)
                dismiss()
            }
        }
    }

    private func commitDelete() {
        Task {
            let didChange = await viewModel.delete(categoryName, in: habits, context: context, syncsToServer: appState.isAuthenticated)
            if didChange {
                HapticManager.trigger(.warning)
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(categoryName: "Fitness")
            .environmentObject(AppState())
    }
}

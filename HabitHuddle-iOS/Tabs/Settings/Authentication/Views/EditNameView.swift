//
//  EditNameView.swift
//  HabitHuddle-iOS
//

import SwiftUI

struct EditNameView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var userManager: LocalUserManager

    @StateObject private var viewModel = AccountSettingsViewModel()

    @State private var name: String = ""
    @State private var didLoad = false

    @FocusState private var focused: Bool

    private var trimmed: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var disabled: Bool {
        trimmed.isEmpty || trimmed == userManager.profile.name || viewModel.isSubmitting
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                FormHeader(icon: "person.text.rectangle", title: .editName, subtitle: nil)
                FormErrorBanner(message: viewModel.errorMessage)

                FormCard {
                    FormFieldRow(icon: "person.text.rectangle", color: .blue) {
                        TextField(String(localized: .enterYourName), text: $name)
                            .textContentType(.name)
                            .submitLabel(.done)
                            .focused($focused)
                            .onSubmit { submit() }
                    }
                }

                FormPrimaryButton(
                    title: .saveChanges,
                    isLoading: viewModel.isSubmitting,
                    disabled: disabled,
                    action: submit
                )
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(String(localized: .editName))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if !didLoad {
                name = userManager.profile.name
                didLoad = true
                focused = true
            }
        }
        .onChange(of: viewModel.lastUpdatedUser) { _, newValue in
            guard let newValue else { return }
            applyUpdate(newValue)
            HapticManager.trigger(.success)
            dismiss()
        }
    }

    private func submit() {
        focused = false
        Task {
            await viewModel.updateName(newName: name, currentName: userManager.profile.name)
        }
    }

    private func applyUpdate(_ user: UserDTO) {
        userManager.profile = LocalUser(
            id: user.id,
            username: user.username,
            name: user.name,
            email: user.email ?? userManager.profile.email,
            isSignedInToServer: true,
            isEmailVerified: user.isEmailVerified,
            authProvider: user.authProvider
        )
    }
}

#Preview {
    NavigationStack {
        EditNameView()
            .environmentObject(LocalUserManager())
    }
}

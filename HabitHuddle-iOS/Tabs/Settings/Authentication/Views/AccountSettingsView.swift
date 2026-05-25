//
//  AccountSettingsView.swift
//  HabitHuddle-iOS
//

import SwiftUI

struct AccountSettingsView: View {

    @EnvironmentObject private var userManager: LocalUserManager

    private var isSSOUser: Bool {
        userManager.profile.isSSOUser
    }

    private var providerCaption: String? {
        switch userManager.profile.authProvider {
        case .apple: return String(localized: .managedByApple)
        case .google: return String(localized: .managedByGoogle)
        case .password: return nil
        }
    }

    var body: some View {
        List {
            Section(header: Text(.profile)) {
                NavigationLink(destination: EditNameView()) {
                    row(icon: "person.text.rectangle", color: .blue, label: Text(.name), value: userManager.profile.name)
                }

                NavigationLink(destination: EditUsernameView()) {
                    row(icon: "at", color: .blue, label: Text(.username), value: userManager.profile.username)
                }

                if isSSOUser {
                    emailRow
                } else {
                    NavigationLink(destination: ChangeEmailView()) {
                        emailRow
                    }
                }
            }

            if !isSSOUser {
                Section(header: Text(.security)) {
                    NavigationLink(destination: ChangePasswordView()) {
                        HStack(spacing: 12) {
                            rowIcon("lock.fill", color: .purple)
                            Text(.changePassword)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(String(localized: .editProfile))
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            // Manual override for the case where the verification webhook didn't
            // round-trip — pulls fresh state from /me and rewrites the local profile.
            _ = try? await userManager.refreshFromServer()
        }
    }

    // MARK: - Rows

    private func row(icon: String, color: Color, label: Text, value: String) -> some View {
        HStack(spacing: 12) {
            rowIcon(icon, color: color)
            label
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var emailRow: some View {
        HStack(spacing: 12) {
            rowIcon("envelope.fill", color: .green)
            Text(.email)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(userManager.profile.email ?? "…")
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let providerCaption {
                    Text(providerCaption)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                } else if userManager.profile.email != nil {
                    Text(userManager.profile.isEmailVerified ? String(localized: .verified) : String(localized: .notVerified))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(userManager.profile.isEmailVerified ? .green : .orange)
                }
            }
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
        AccountSettingsView()
            .environmentObject(LocalUserManager())
    }
}

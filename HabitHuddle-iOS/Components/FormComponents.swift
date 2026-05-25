//
//  FormComponents.swift
//  HabitHuddle-iOS
//
//  Shared form building blocks used by Account Settings edit screens.
//  Visual language mirrors the form pattern in ResetPasswordView / ForgotPasswordView.
//

import SwiftUI

struct FormHeader: View {
    let icon: String
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource?

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 16)
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct FormErrorBanner: View {
    let message: String

    var body: some View {
        if !message.isEmpty {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.subheadline)
                Text(message)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

struct FormCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct FormFieldRow<Content: View>: View {
    let icon: String
    let color: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 28, height: 28)
                .foregroundStyle(.white)
                .background(color.gradient)
                .clipShape(.rect(cornerRadius: 7))
                .padding(.leading, 12)

            content()
        }
        .frame(minHeight: 48)
        .padding(.vertical, 2)
        .padding(.trailing, 12)
    }
}

struct FormCardDivider: View {
    var body: some View {
        Divider().padding(.leading, 52)
    }
}

struct FormPrimaryButton: View {
    let title: LocalizedStringResource
    let isLoading: Bool
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView().tint(.white)
                }
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
        }
        .background(disabled || isLoading ? Color.accentColor.opacity(0.4) : Color.accentColor)
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal)
        .disabled(disabled || isLoading)
        .animation(.easeInOut(duration: 0.15), value: disabled)
    }
}

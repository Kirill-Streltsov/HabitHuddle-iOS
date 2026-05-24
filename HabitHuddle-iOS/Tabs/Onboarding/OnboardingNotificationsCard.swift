//
//  OnboardingNotificationsCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct OnboardingNotificationsCard: View {
    var body: some View {
        VStack(spacing: 12) {
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image("AppIconPreview")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text("Habit Huddle")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Spacer()

                        Text(.justNow)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(.timeToCheckIn)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(.yourStreakIsWaitingDontLetItSlip)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            CardView {
                HStack(spacing: 16) {
                    NotificationFeatureRow(
                        symbol: "clock.fill",
                        color: .blue,
                        label: .dailyReminders
                    )

                    Divider()
                        .frame(height: 36)

                    NotificationFeatureRow(
                        symbol: "bolt.circle.fill",
                        color: .orange,
                        label: .friendBoosts
                    )

                    Divider()
                        .frame(height: 36)

                    NotificationFeatureRow(
                        symbol: "trophy.fill",
                        color: .yellow,
                        label: .challenges
                    )
                }
            }
        }
    }
}

private struct NotificationFeatureRow: View {
    let symbol: String
    let color: Color
    let label: LocalizedStringResource

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingNotificationsCard()
        .background(Color(.systemGroupedBackground))
}

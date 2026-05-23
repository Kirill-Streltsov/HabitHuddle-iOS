import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .frame(maxWidth: .infinity)

                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 28) {
                    descriptionSection
                    featuresSection
                    contactSection
                }
                .padding()

                Divider()
                    .padding(.top, 8)

                Text("© 2025 Habit Huddle. All rights reserved.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            }
        }
        .navigationTitle(String(localized: .about))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            Group {
                if let uiImage = UIImage(named: "AppIcon") {
                    Image(uiImage: uiImage)
                        .resizable()
                } else {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .resizable()
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

            Text("Habit Huddle")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 4) {
                Text(.version)
                    .foregroundStyle(.secondary)
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 32)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(.habitHuddleIsYourPersonalHabitCompanion)
                .font(.body)
                .fontWeight(.medium)
            Text(.buildMeaningfulRoutinesTrackYourProgressAndStayMotivatedEveryDay)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(.features)
                .font(.headline)

            FeatureRow(icon: "chart.line.uptrend.xyaxis",  text: .trackDailyHabitsWithBeautifulStreakVisualizations)
            FeatureRow(icon: "icloud.and.arrow.up",        text: .syncHabitsAcrossAllYourDevices)
            FeatureRow(icon: "person.2.fill",              text: .challengeFriendsAndGrowTogether)
            FeatureRow(icon: "sparkles",                   text: .intelligentSuggestionsTailoredToYourGoals)
            FeatureRow(icon: "bell.fill",                  text: .setRemindersSoYouNeverMissACheckIn)
        }
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.helpFeedback)
                .font(.headline)
            Text(.haveQuestionsOrFeedbackWedLoveToHearFromYou)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Link("support@habithuddle.app", destination: URL(string: "mailto:support@habithuddle.app")!)
                .font(.subheadline)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: LocalizedStringResource

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .font(.callout)
                .frame(width: 22, alignment: .center)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

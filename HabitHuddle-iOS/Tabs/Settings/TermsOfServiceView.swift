import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                Divider()

                VStack(alignment: .leading, spacing: 28) {
                    LegalSection(number: 1, title: .acceptanceOfTerms) {
                        BodyText(text: .byUsingHabitHuddleYouAgreeToTheseTermsOfService)
                        BodyText(text: .ifYouDoNotAgreePleaseDoNotUseTheApp)
                    }

                    LegalSection(number: 2, title: .userAccounts) {
                        BulletRow(text: .youMustBe13OrOlderToUseHabitHuddle)
                        BulletRow(text: .keepYourLoginCredentialsSecureAndDoNotShareThem)
                        BulletRow(text: .youAreResponsibleForAllActivityUnderYourAccount)
                        BulletRow(text: .youMayDeleteYourAccountAtAnyTimeFromSettings)
                    }

                    LegalSection(number: 3, title: .acceptableUse) {
                        BulletRow(text: .doNotUseTheAppForAnyUnlawfulPurpose)
                        BulletRow(text: .doNotAttemptToAccessOtherUsersData)
                        BulletRow(text: .doNotInterfereWithTheAppsFunctionalityOrSecurity)
                        BulletRow(text: .doNotReverseEngineerOrCopyAnyPartOfTheApp)
                    }

                    LegalSection(number: 4, title: .contentData) {
                        BulletRow(text: .youOwnTheHabitDataYouCreateInHabitHuddle)
                        BulletRow(text: .publicContentYouShareMayBeVisibleToOtherUsers)
                        BulletRow(text: .weMayRemoveContentThatViolatesTheseTerms)
                    }

                    LegalSection(number: 5, title: .serviceAvailability) {
                        BodyText(text: .weStriveToKeepHabitHuddleRunningSmoothlyAndReliably)
                        BodyText(text: .featuresMayChangeOrBeDiscontinuedWithReasonableNotice)
                    }

                    LegalSection(number: 6, title: .accountTermination) {
                        BodyText(text: .weMaySuspendYourAccountIfYouViolateTheseTerms)
                        BodyText(text: .youMayDeleteYourAccountAtAnyTimeFromSettings)
                    }

                    LegalSection(number: 7, title: .disclaimer) {
                        BodyText(text: .habitHuddleIsProvidedAsIsWithoutWarrantiesOfAnyKind)
                    }

                    LegalSection(number: 8, title: .changesToTheseTerms) {
                        BodyText(text: .weMayUpdateTheseTermsPeriodically)
                        BodyText(text: .continuedUseOfTheAppMeansYouAcceptTheUpdatedTerms)
                    }

                    LegalSection(number: 9, title: .legalContact) {
                        BodyText(text: .questionsAboutTheseTermsReachUsAt)
                        Link("legal@habithuddle.app", destination: URL(string: "mailto:legal@habithuddle.app")!)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(String(localized: .termsOfService))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(.termsOfService)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(.effectiveJanuary12025)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}

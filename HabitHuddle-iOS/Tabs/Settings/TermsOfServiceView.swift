import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                Divider()

                VStack(alignment: .leading, spacing: 28) {
                    LegalSection(number: 1, title: .acceptanceOfTerms) {
                        BodyText(text: .byAccessingOrUsingHabitHuddleYouAgreeToTheseTermsOfServiceAndOurPrivacyPolicy)
                        BodyText(text: .ifYouDoNotAgreePleaseDiscontinueUseOfTheApp)
                    }

                    LegalSection(number: 2, title: .userAccounts) {
                        BulletRow(text: .youMustBeAtLeast13YearsOfAgeToCreateAnAccount)
                        BulletRow(text: .youAreResponsibleForMaintainingTheConfidentialityOfYourLoginCredentials)
                        BulletRow(text: .youAreSolelyResponsibleForAllActivityThatOccursUnderYourAccount)
                        BulletRow(text: .youMayDeleteYourAccountAtAnyTimeFromSettings)
                    }

                    LegalSection(number: 3, title: .acceptableUse) {
                        BulletRow(text: .doNotUseTheAppForAnyUnlawfulOrUnauthorisedPurpose)
                        BulletRow(text: .doNotAttemptToGainUnauthorisedAccessToOtherAccountsOrOurSystems)
                        BulletRow(text: .doNotInterfereWithOrDisruptTheAppsOperationOrSecurity)
                        BulletRow(text: .doNotReverseEngineerDecompileOrReproduceAnyPartOfTheApp)
                    }

                    LegalSection(number: 4, title: .contentData) {
                        BulletRow(text: .youRetainOwnershipOfTheHabitDataYouCreateInHabitHuddle)
                        BulletRow(text: .habitsYouShareWithFriendsMayBeVisibleToYourConnectedFriends)
                        BulletRow(text: .weMayRemoveContentThatViolatesTheseTerms)
                    }

                    LegalSection(number: 5, title: .serviceAvailability) {
                        BodyText(text: .weStriveToProvideAReliableContinuouslyAvailableService)
                        BodyText(text: .featuresMayBeModifiedOrDiscontinuedWithReasonablePriorNotice)
                    }

                    LegalSection(number: 6, title: .accountTermination) {
                        BodyText(text: .weMaySuspendOrTerminateYourAccountIfYouMateriallyBreachTheseTerms)
                        BodyText(text: .youMayCloseYourAccountAtAnyTimeFromSettingsPermanentlyDeletingAllAssociatedData)
                    }

                    LegalSection(number: 7, title: .disclaimer) {
                        BodyText(text: .habitHuddleIsProvidedAsIsAndAsAvailableWithoutWarrantiesOfAnyKind)
                        BodyText(text: .weDoNotWarrantThatTheAppWillBeUninterruptedErrorFreeOrSecure)
                    }

                    LegalSection(number: 8, title: .changesToTheseTerms) {
                        BodyText(text: .weMayReviseTheseTermsAtAnyTimeAndWillNotifyYouOfMaterialChangesThroughTheApp)
                        BodyText(text: .continuedUseOfHabitHuddleAfterChangesTakeEffectConstitutesAcceptanceOfTheRevisedTerms)
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

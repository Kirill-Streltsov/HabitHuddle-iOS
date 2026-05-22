import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                Divider()

                VStack(alignment: .leading, spacing: 28) {
                    LegalSection(number: 1, title: .informationWeCollect) {
                        BulletRow(text: .accountDataUsernameNameAndEmailAddress)
                        BulletRow(text: .habitDataYourHabitsCheckInsAndStreaks)
                        BulletRow(text: .habitSyncIsEnabledByDefaultWhenSignedInYouCanDisableItPerHabitOrBySigningOut)
                        BulletRow(text: .weStoreYourHabitDataSolelyToSyncItAcrossYourDevicesAndNeverUseItForAnyOtherPurpose)
                        BulletRow(text: .deviceTokenForSendingPushNotifications)
                        BulletRow(text: .anonymousUsageAnalyticsToImproveTheApp)
                    }

                    LegalSection(number: 2, title: .howWeUseYourData) {
                        BulletRow(text: .toProvideAndImproveHabitHuddlesFeatures)
                        BulletRow(text: .toSendHabitRemindersAndSocialNotifications)
                        BulletRow(text: .toEnableSocialFeaturesLikeChallengesAndFriends)
                    }

                    LegalSection(number: 3, title: .dataSharing) {
                        BodyText(text: .weDoNotSellYourPersonalDataToThirdParties)
                        BodyText(text: .weShareDataOnlyWithServiceProvidersThatHelpUsOperateTheApp)
                        BodyText(text: .weMayDiscloseDataWhenRequiredByLaw)
                    }

                    LegalSection(number: 4, title: .dataSecurity) {
                        BodyText(text: .weUseEncryptedConnectionsAndSecureStorageToProtectYourData)
                        BodyText(text: .noSystemIsCompletelySecureButWeTakeEveryPrecaution)
                    }

                    LegalSection(number: 5, title: .yourRights) {
                        BulletRow(text: .youCanAccessAndExportYourDataAtAnyTime)
                        BulletRow(text: .youCanDeleteYourAccountAndAllDataFromSettings)
                        BulletRow(text: .youCanOptOutOfMarketingCommunicationsAtAnyTime)
                    }

                    LegalSection(number: 6, title: .pushNotifications) {
                        BodyText(text: .weUseYourDeviceTokenToSendRemindersAndSocialAlerts)
                        BodyText(text: .youCanDisableNotificationsInYourDevicesNotificationSettings)
                    }

                    LegalSection(number: 7, title: .thirdPartyServices) {
                        BodyText(text: .usesTrustedThirdPartyProvidersForAuthentication)
                        BodyText(text: .eachThirdPartyServiceHasItsOwnPrivacyPolicy)
                    }

                    LegalSection(number: 8, title: .childrensPrivacy) {
                        BodyText(text: .habitHuddleIsNotIntendedForUsersUnder13YearsOfAge)
                    }

                    LegalSection(number: 9, title: .changesToThisPolicy) {
                        BodyText(text: .weMayUpdateThisPrivacyPolicyFromTimeToTime)
                        BodyText(text: .weWillNotifyYouOfSignificantChangesThroughTheApp)
                    }

                    LegalSection(number: 10, title: .privacyContact) {
                        BodyText(text: .questionsAboutPrivacyContactUsAt)
                        Link("privacy@habithuddle.app", destination: URL(string: "mailto:privacy@habithuddle.app")!)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(String(localized: .privacyPolicy))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(.privacyPolicy)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(.effectiveJanuary12025)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(.weValueYourPrivacyAndAreCommittedToProtectingIt)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}

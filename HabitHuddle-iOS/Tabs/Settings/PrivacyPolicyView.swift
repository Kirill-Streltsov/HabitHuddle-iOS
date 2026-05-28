import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                Divider()

                VStack(alignment: .leading, spacing: 28) {
                    LegalSection(number: 1, title: .informationWeCollect) {
                        BulletRow(text: .accountInformationYourUsernameDisplayNameAndEmailAddress)
                        BulletRow(text: .habitDataYourHabitsDailyCheckInsAndStreakHistory)
                        BulletRow(text: .habitSyncIsEnabledByDefaultWhenSignedInYouCanDisableItPerHabitOrBySigningOut)
                        BulletRow(text: .weStoreYourHabitDataSolelyToSyncItAcrossYourDevicesAndNeverUseItForAnyOtherPurpose)
                        BulletRow(text: .deviceTokenUsedExclusivelyToDeliverPushNotifications)
                        BulletRow(text: .anonymousAggregatedUsageAnalyticsToImproveTheApp)
                    }

                    LegalSection(number: 2, title: .howWeUseYourData) {
                        BulletRow(text: .toOperateMaintainAndImproveHabitHuddlesFeatures)
                        BulletRow(text: .toDeliverHabitRemindersAndSocialNotifications)
                        BulletRow(text: .toEnableSocialFeaturesSuchAsChallengesAndTheFriendsNetwork)
                    }

                    LegalSection(number: 3, title: .dataSharing) {
                        BodyText(text: .weDoNotSellYourPersonalDataToThirdParties)
                        BodyText(text: .weShareDataOnlyWithServiceProvidersThatHelpUsOperateTheApp)
                        BodyText(text: .weMayDiscloseDataWhenRequiredByApplicableLawOrLegalProcess)
                    }

                    LegalSection(number: 4, title: .dataSecurity) {
                        BodyText(text: .allDataIsTransmittedOverEncryptedConnectionsAndStoredSecurely)
                        BodyText(text: .whileWeApplyIndustryStandardSafeguardsNoSystemCanGuaranteeAbsoluteSecurity)
                    }

                    LegalSection(number: 5, title: .yourRights) {
                        BulletRow(text: .youMayAccessAndExportYourDataAtAnyTimeFromTheApp)
                        BulletRow(text: .youMayPermanentlyDeleteYourAccountAndAllDataFromSettings)
                        BulletRow(text: .youMayWithdrawConsentToMarketingCommunicationsAtAnyTime)
                    }

                    LegalSection(number: 6, title: .pushNotifications) {
                        BodyText(text: .weUseYourDeviceTokenSolelyToSendHabitRemindersAndSocialAlerts)
                        BodyText(text: .youCanDisableNotificationsAtAnyTimeInYourDevicesSystemSettings)
                    }

                    LegalSection(number: 7, title: .thirdPartyServices) {
                        BodyText(text: .weUseTrustedThirdPartyProvidersForAuthenticationAndCloudInfrastructure)
                        BodyText(text: .eachThirdPartyServiceHasItsOwnPrivacyPolicy)
                    }

                    LegalSection(number: 8, title: .childrensPrivacy) {
                        BodyText(text: .habitHuddleIsNotDirectedAtChildrenUnder13WeDoNotKnowinglyCollectDataFromUsersUnder13)
                    }

                    LegalSection(number: 9, title: .changesToThisPolicy) {
                        BodyText(text: .weMayUpdateThisPrivacyPolicyFromTimeToTime)
                        BodyText(text: .weWillNotifyYouOfMaterialChangesThroughTheAppBeforeTheyTakeEffect)
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
            Text(.weAreCommittedToProtectingYourPrivacyAndHandlingYourDataResponsibly)
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

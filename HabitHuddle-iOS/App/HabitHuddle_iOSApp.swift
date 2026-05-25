//
//  HabitHuddle_iOSApp.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 14.05.25.
//

import SwiftData
import SwiftUI
import GoogleSignIn
import UserNotifications

@main
struct HabitHuddle_iOSApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var appState = AppState()
    @StateObject private var userManager = LocalUserManager()
    
    init() {
        AppLaunchChecker.clearKeychainIfFreshInstall()
        print("TOKEN MANAGER: \(String(describing: TokenManager.token))")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(userManager)
                .environmentObject(MyFriendsList.ViewModel())
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        print("Resorted user from google: \(String(describing: user))")
                    }
                }
                .onAppear {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            
        }
        .modelContainer(sharedModelContainer)
    }
    
    var sharedModelContainer: ModelContainer = {
        guard let container = SharedModelContainer.make() else {
            fatalError("Could not create ModelContainer")
        }
        return container
    }()
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    @AppStorage("deviceToken") private var token: String = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        if let activityDictionary = launchOptions?[.userActivityDictionary] as? [AnyHashable: Any] {
            for case let activity as NSUserActivity in activityDictionary.values {
                if DeepLinkState.shared.handle(activity) { break }
            }
        }

        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        DeepLinkState.shared.handle(userActivity)
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        token = tokenString
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for push notifications: \(error)")
    }
}

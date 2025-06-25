//
//  HabitHuddle_iOSApp.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 14.05.25.
//

import SwiftData
import SwiftUI
import GoogleSignIn

@main
struct HabitHuddle_iOSApp: App {

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
                .environmentObject(MyFriendsListView.ViewModel())
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        print("USER: \(user)")
                    }
                }
            
        }
        .modelContainer(sharedModelContainer)
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Habit.self,
            Challenge.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}

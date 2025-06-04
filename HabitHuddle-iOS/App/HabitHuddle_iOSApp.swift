//
//  HabitHuddle_iOSApp.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 14.05.25.
//

import SwiftData
import SwiftUI

@main
struct HabitHuddle_iOSApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var appState = AppState()
    @StateObject private var user = LocalUserManager()

    init() {
        AppLaunchChecker.clearKeychainIfFreshInstall()
        print("TOKEN MANAGER: \(String(describing: TokenManager.token))")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(user)
                .environmentObject(FriendsListView.ViewModel())
                .onAppear {
                    for op in SyncManager.shared.operations {
                        print("OPERATION: \(op)")
                    }
                }
            
        }
        .modelContainer(sharedModelContainer)
    }
}

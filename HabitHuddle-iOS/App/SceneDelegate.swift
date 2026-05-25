//
//  SceneDelegate.swift
//  HabitHuddle-iOS
//

import SwiftUI
import GoogleSignIn

/// Receives universal-link `NSUserActivity` and URL events from the scene lifecycle
/// and routes them to `DeepLinkState.shared` / Google Sign-In. SwiftUI's
/// `.onContinueUserActivity` modifier and the `UIApplicationDelegate` continuation
/// method are both unreliable for cold-starts in SwiftUI `WindowGroup` apps — the
/// scene path is the one iOS actually invokes, so we own it explicitly.
final class SceneDelegate: NSObject, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        for activity in connectionOptions.userActivities {
            if DeepLinkState.shared.handle(activity) { break }
        }
        for context in connectionOptions.urlContexts {
            _ = GIDSignIn.sharedInstance.handle(context.url)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        _ = DeepLinkState.shared.handle(userActivity)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            _ = GIDSignIn.sharedInstance.handle(context.url)
        }
    }
}

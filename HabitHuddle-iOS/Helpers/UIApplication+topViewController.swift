//
//  UIApplication+topViewController.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.06.25.
//

import UIKit

extension UIApplication {
    static func topViewController(base: UIViewController? = {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        return scene.windows.first(where: \.isKeyWindow)?.rootViewController
    }()) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

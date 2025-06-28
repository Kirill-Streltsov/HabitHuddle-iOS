//
//  UIApplication+endEditing.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.06.25.
//

import UIKit
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

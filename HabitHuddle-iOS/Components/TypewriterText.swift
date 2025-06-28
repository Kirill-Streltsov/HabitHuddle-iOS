//
//  TypewriterText.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.06.25.
//

import SwiftUI

struct TypewriterText: View {
    let text: String
    let typingInterval = 0.025

    @State private var displayedText: String = ""
    @State private var charIndex = 0
    @State private var timer: Timer?

    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }

    private func startTyping() {
        displayedText = ""
        charIndex = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: typingInterval, repeats: true) { _ in
            if charIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: charIndex)
                displayedText.append(text[index])
                charIndex += 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    TypewriterText(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
}

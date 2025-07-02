//
//  TypewriterText.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.06.25.
//

import SwiftUI

struct TypewriterText: View {
    let text: String
    let typingInterval: Double

    @State private var displayedText: String = ""
    @State private var charIndex = 0

    init(text: String, typingInterval: Double = 0.01) {
        self.text = text
        self.typingInterval = typingInterval
    }

    var body: some View {
        Text(displayedText)
            .font(.body)
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
            .lineSpacing(4)
            .padding(.horizontal)
            .task {
                if typingInterval != 0 {
                    await startTyping()
                } else {
                    displayedText = text
                }
            }
    }

    private func startTyping() async {
        displayedText = ""
        charIndex = 0

        for character in text {
            await MainActor.run {
                displayedText.append(character)
                charIndex += 1
            }
            try? await Task.sleep(nanoseconds: UInt64(typingInterval * 1_000_000_000))
        }
    }
}

#Preview {
    TypewriterText(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
}

//
//  Flicker+flickering.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 16.06.25.
//

import SwiftUI

struct Flicker: ViewModifier {
    @State private var isVisible = true
    let shouldFlicker: Bool

    func body(content: Content) -> some View {
        if shouldFlicker {
            content
                .opacity(isVisible ? 1 : 0.3)
                .animation(
                    Animation.easeInOut(duration: 0.75)
                        .repeatForever(autoreverses: true),
                    value: isVisible
                )
                .onAppear {
                    isVisible.toggle()
                }
        } else {
            content
        }
    }
}

extension View {
    func flickering(shouldFlicker: Bool) -> some View {
        self.modifier(Flicker(shouldFlicker: shouldFlicker))
    }
}

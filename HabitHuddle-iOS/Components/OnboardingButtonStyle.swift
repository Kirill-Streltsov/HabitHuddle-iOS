//
//  OnboardingButtonStyle.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//
import SwiftUI

struct OnboardingButtonStyle: ButtonStyle {
    var style: OnboardingButtonStyleType

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(style == .primary ? Color.accentColor : Color.clear)
            .foregroundStyle(style == .primary ? .white : .accentColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: style == .primary ? 0 : 2)
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

enum OnboardingButtonStyleType {
    case primary, secondary
}

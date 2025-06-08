//
//  OnboardingContent.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//
import SwiftUI

struct OnboardingContent: View {
    var page: OnboardingPageData

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: page.symbol)
                .font(.system(size: 48))
                .foregroundStyle(.primary)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                            
                Text(page.text)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            
            page.customView
        }
        .padding(.top, 32)
    }
}

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
        VStack(spacing: 20) {
            Image(systemName: page.symbol)
                .font(.system(size: 60))
                .foregroundColor(.primary)

            Text(page.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                        
            Text(page.text)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()

            page.customView
            
            Spacer()
        }
        .padding(.top, 32)
    }
}

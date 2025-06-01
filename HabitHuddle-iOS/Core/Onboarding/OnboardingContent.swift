//
//  OnboardingContent.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//
import SwiftUI

struct OnboardingContent: View {
    var page: OnboardingPageData
    var namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 24) {
            
            Image(systemName: page.symbol)
                .font(.system(size: 60))
                .foregroundColor(.primary)
                .transition(.opacity.combined(with: .move(edge: .top)))
            
            Text(page.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .transition(.slide)
                .matchedGeometryEffect(id: "title\(page.title)", in: namespace)
            
            Text(page.text)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .transition(.slide)

            page.customView
        }
        .padding(.top, 60)
        .animation(.easeInOut, value: page.title)
    }
}

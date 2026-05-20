//
//  UnauthenticatedChallengesView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct UnauthenticatedView: View {
    
    @AppStorage("selectedTab") private var selectedTab: Int?
    let description: LocalizedStringResource
    
    var body: some View {
        CardView {
            VStack(spacing: 20) {
                Image(systemName: "person.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(.gray.opacity(0.4))

                Text("Not Signed In")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary.opacity(0.7))

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button(action: { selectedTab = 3 }) {
                    Text("Go to Settings")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: 220)
                        .background(Color(.systemBlue))
                        .cornerRadius(12)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

#Preview {
    UnauthenticatedView(description: "Some description")
}

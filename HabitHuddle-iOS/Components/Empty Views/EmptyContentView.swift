//
//  EmptyContentView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import SwiftUI

struct EmptyContentView: View {
    
    let icon: String
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    
    var body: some View {
        CardView {
            VStack(alignment: .center, spacing: 20) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(.gray.opacity(0.4))

                Text(title)
                    .multilineTextAlignment(.center)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary.opacity(0.7))

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}


#Preview {
    EmptyContentView(icon: "person", title: "No title", description: "No long description provided because this is a preview")
}

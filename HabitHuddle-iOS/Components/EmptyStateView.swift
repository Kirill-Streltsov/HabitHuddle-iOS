//
//  EmptyStateView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.05.25.
//

import SwiftUI

import SwiftUI

struct EmptyStateView: View {
    var title: String
    var subtitle: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 24) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 240, height: 150)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding()
        }
    }
}

#Preview {
    EmptyStateView(title: "You don't have any habits yet", subtitle: "Add your first one!", action: {})
}

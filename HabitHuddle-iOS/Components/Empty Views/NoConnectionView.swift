//
//  NoConnectionView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 03.06.25.
//

import SwiftUI

struct NoConnectionView: View {
    let errorMessage: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(.gray.opacity(0.4))

            Text("No Internet Connection")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.7))

            Text(errorMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    NoConnectionView(errorMessage: "No WiFi")
}

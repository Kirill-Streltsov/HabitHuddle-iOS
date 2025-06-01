//
//  EmptyStatisticsView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct EmptyStatisticsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(.gray.opacity(0.4))
            
            Text("No stats yet")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary.opacity(0.7))
            
            Text("You don't have any habits yet, so there are no statistics to display. Start building your habits and watch your progress here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    EmptyStatisticsView()
}

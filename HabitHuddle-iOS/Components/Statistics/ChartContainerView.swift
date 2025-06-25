//
//  ChartContainerView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.06.25.
//

import SwiftUI

struct ChartContainerView<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content
    
    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            content
        }
    }
}

#Preview {
    ChartContainerView(title: "Frequency of your check ins") {}
}

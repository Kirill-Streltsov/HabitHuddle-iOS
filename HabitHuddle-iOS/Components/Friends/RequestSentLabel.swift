//
//  RequestSentLabel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 03.06.25.
//

import SwiftUI

struct RequestSentLabel: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.subheadline)

            Text("Request Sent")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    RequestSentLabel()
}

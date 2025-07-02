//
//  InfoView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 30.06.25.
//
import SwiftUI

struct InfoView: View {
    @State private var showInfoPopover = false
    let text: String

    var body: some View {
        HStack {
            Button("", systemImage: "info.circle") {
                showInfoPopover.toggle()
            }
            .popover(isPresented: $showInfoPopover) {
                Text(text)
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 250)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }
}

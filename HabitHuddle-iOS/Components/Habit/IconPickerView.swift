//
//  IconPickerView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.06.25.
//

import SwiftUI

struct IconCategory: Identifiable {
    let id = UUID()
    let name: LocalizedStringResource
    let icons: [String]
}

struct IconPickerView: View {
    @Binding var selectedIcon: String?
    
    private let categories: [IconCategory] = [
        IconCategory(name: .healthFitness, icons: [
            "figure.walk", "figure.run", "bicycle", "dumbbell", "heart.fill", "flame", "bandage", "lungs.fill", "drop.fill"
        ]),
        IconCategory(name: .mindfulnessSleep, icons: [
            "brain.head.profile", "waveform.path.ecg", "sparkles", "moon.zzz", "medal.fill", "wind", "eye", "face.smiling", "wifi.slash"
        ]),
        IconCategory(name: .productivity, icons: [
            "calendar", "clock", "pencil", "lightbulb", "bookmark.fill", "doc.text", "tray.full", "folder.fill", "gear"
        ]),
        IconCategory(name: .learning, icons: [
            "book.fill", "graduationcap", "brain", "highlighter", "books.vertical", "magnifyingglass", "rectangle.and.pencil.and.ellipsis"
        ]),
        IconCategory(name: .selfCareLifestyle, icons: [
            "leaf.fill", "drop", "hands.sparkles", "fork.knife", "bed.double.fill", "face.smiling.fill", "sparkles.tv"
        ]),
        IconCategory(name: .hobbies, icons: [
            "camera", "paintpalette", "gamecontroller", "guitars", "music.note", "tennis.racket", "film", "puzzlepiece"
        ]),
        IconCategory(name: .workCareer, icons: [
            "briefcase.fill", "chart.bar", "chart.line.uptrend.xyaxis", "laptopcomputer", "network", "person.2.wave.2", "case.fill"
        ]),
        IconCategory(name: .motivationRewards, icons: [
            "trophy.fill", "star.fill", "checkmark.circle", "flag.fill", "rosette", "medal", "target", "crown.fill"
        ]),
        IconCategory(name: .homeDailyLife, icons: [
            "house.fill", "house.and.flag", "bed.double", "washer", "trash", "lightbulb.fill", "sink", "wrench"
        ]),
        IconCategory(name: .financeBudgeting, icons: [
            "dollarsign.circle", "creditcard.fill", "chart.pie.fill", "wallet.pass", "banknote", "chart.bar.fill", "percent"
        ]),
        IconCategory(name: .travelExploration, icons: [
            "airplane", "car.fill", "globe", "location.fill", "map", "suitcase.fill", "ferry.fill"
        ]),
        IconCategory(name: .socialRelationships, icons: [
            "person.2.fill", "heart.circle", "message.fill", "phone.fill", "hands.clap", "face.smiling", "person.crop.circle.badge.plus"
        ]),
        IconCategory(name: .environmentNature, icons: [
            "leaf", "tornado", "sun.max.fill", "cloud.rain.fill", "snow", "drop.degreesign", "globe.americas", "tree"
        ])
    ]
    
    let gridItemLayout = [GridItem(.adaptive(minimum: 44, maximum: 60), spacing: 16)]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(categories) { category in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        LazyVGrid(columns: gridItemLayout, alignment: .leading, spacing: 16) {
                            ForEach(category.icons, id: \.self) { icon in
                                Button(action: {
                                    if selectedIcon == icon {
                                        selectedIcon = nil
                                    } else {
                                        selectedIcon = icon
                                    }
                                }) {
                                    Image(systemName: icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .padding(12)
                                        .background(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color(.tertiarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .scrollIndicators(.never)
        .background(Color(.systemGroupedBackground))
    }
}

// Example usage:
struct IconPickerPreview: View {
    @State private var selectedIcon: String? = "brain"
    
    var body: some View {
        VStack(spacing: 20) {
            if let icon = selectedIcon {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            IconPickerView(selectedIcon: $selectedIcon)
                .frame(height: 550)
        }
        .padding()
    }
}

#Preview {
    IconPickerPreview()
}

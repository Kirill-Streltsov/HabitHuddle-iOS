//
//  ChallengeDurationPickerView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 27.05.26.
//

import SwiftUI

struct ChallengeDurationPickerView: View {

    @Binding var days: Int
    @Binding var isValid: Bool

    private let presets = [7, 14, 21, 30]
    @State private var showCustom = false
    @State private var customText = ""

    private var customTextValid: Bool {
        guard let n = Int(customText) else { return false }
        return n >= 1 && n <= 365
    }

    init(days: Binding<Int>, isValid: Binding<Bool> = .constant(true)) {
        _days = days
        _isValid = isValid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(.duration)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            HStack(spacing: 8) {
                ForEach(presets, id: \.self) { preset in
                    let selected = !showCustom && days == preset
                    Button {
                        showCustom = false
                        customText = ""
                        days = preset
                        isValid = true
                    } label: {
                        Text("\(preset)d")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selected ? Color.accentColor.opacity(0.1) : Color(.secondarySystemBackground))
                            .foregroundStyle(selected ? Color.accentColor : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                Button {
                    showCustom = true
                    customText = ""
                    isValid = false
                } label: {
                    Text(.custom)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(showCustom ? Color.accentColor.opacity(0.1) : Color(.secondarySystemBackground))
                        .foregroundStyle(showCustom ? Color.accentColor : .secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            if showCustom {
                HStack(spacing: 8) {
                    TextField("1–365", text: $customText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 72)
                        .onChange(of: customText) { _, newValue in
                            let filtered = String(newValue.filter { $0.isNumber }.prefix(3))
                            if filtered != newValue { customText = filtered }
                            if let n = Int(filtered), n >= 1, n <= 365 {
                                days = n
                                isValid = true
                            } else {
                                isValid = false
                            }
                        }
                    Text(.days)
                        .foregroundStyle(.secondary)
                    if customTextValid {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))
                    } else if !customText.isEmpty {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: customText)
            }
        }
    }
}

#Preview {
    @Previewable @State var days = 14
    VStack(alignment: .leading) {
        ChallengeDurationPickerView(days: $days)
        Text("Selected: \(days) days")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding()
}

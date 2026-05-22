import SwiftUI

struct LegalSection<Content: View>: View {
    let number: Int?
    let title: LocalizedStringResource
    @ViewBuilder let content: Content

    init(number: Int? = nil, title: LocalizedStringResource, @ViewBuilder content: () -> Content) {
        self.number = number
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                if let number {
                    Text("\(number).")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                Text(title)
                    .font(.headline)
            }
            content
        }
    }
}

struct BulletRow: View {
    let text: LocalizedStringResource

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.secondary)
                .font(.subheadline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct BodyText: View {
    let text: LocalizedStringResource

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

import SwiftUI

// MARK: - Elevation (performance tiers)

/// Shadow is applied only for `.raised` and above.
/// List cells should use `.flat` to keep scrolling smooth.
enum DepthElevation {
    case flat
    case raised
    case floating
    case hero

    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 4
        case .floating: return 8
        case .hero: return 10
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 2
        case .floating: return 4
        case .hero: return 5
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .flat: return 0
        case .raised: return 0.28
        case .floating: return 0.34
        case .hero: return 0.4
        }
    }
}

enum SurfacePalette {
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.92),
                Color("AppBackground").opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppPrimary").opacity(0.22),
                Color("AppBackground").opacity(0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppPrimary").opacity(0.5),
                Color("AppAccent").opacity(0.22),
                Color("AppTextSecondary").opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var highlightGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppTextPrimary").opacity(0.14),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.78)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct DepthSurface: View {
    var cornerRadius: CGFloat = 16
    var bordered: Bool = true
    var elevation: DepthElevation = .raised
    var usesHeroGradient: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(usesHeroGradient ? SurfacePalette.heroGradient : SurfacePalette.cardGradient)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(SurfacePalette.highlightGradient)
            }
            .overlay {
                if bordered {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(SurfacePalette.borderGradient, lineWidth: 1)
                }
            }
    }
}

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var bordered: Bool = true
    var elevation: DepthElevation = .raised
    var usesHeroGradient: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                DepthSurface(
                    cornerRadius: cornerRadius,
                    bordered: bordered,
                    elevation: elevation,
                    usesHeroGradient: usesHeroGradient
                )
            )
            .modifier(DepthShadowModifier(elevation: elevation))
    }
}

struct DepthShadowModifier: ViewModifier {
    let elevation: DepthElevation

    func body(content: Content) -> some View {
        if elevation == .flat {
            content
        } else {
            content
                .compositingGroup()
                .shadow(
                    color: Color("AppBackground").opacity(elevation.shadowOpacity),
                    radius: elevation.shadowRadius,
                    y: elevation.shadowY
                )
        }
    }
}

extension View {
    func glassCard(
        cornerRadius: CGFloat = 16,
        bordered: Bool = true,
        elevation: DepthElevation = .raised
    ) -> some View {
        modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            bordered: bordered,
            elevation: elevation
        ))
    }

    func heroCard(cornerRadius: CGFloat = 22) -> some View {
        modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            bordered: true,
            elevation: .hero,
            usesHeroGradient: true
        ))
    }

    func depthShadow(_ elevation: DepthElevation) -> some View {
        modifier(DepthShadowModifier(elevation: elevation))
    }
}

// MARK: - Shared UI

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(action: {
                    HapticManager.lightTap()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct TagPill: View {
    let text: String
    var icon: String?
    var tint: Color = Color("AppPrimary")

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.22), tint.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Capsule()
                        .stroke(tint.opacity(0.28), lineWidth: 0.5)
                }
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var usesEmoji: Bool = false
    var emoji: String?

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.3), Color("AppSurface")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Circle()
                            .stroke(Color("AppPrimary").opacity(0.25), lineWidth: 1)
                    }
                    .frame(width: 96, height: 96)

                if usesEmoji, let emoji {
                    Text(emoji)
                        .font(.system(size: 42))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .depthShadow(.raised)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 24)
    }
}

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppTextSecondary"))

            TextField(placeholder, text: $text)
                .foregroundStyle(Color("AppTextPrimary"))
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    HapticManager.lightTap()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 14, elevation: .flat)
    }
}

struct ScreenStatsStrip: View {
    let items: [(value: String, label: String, icon: String)]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(spacing: 10) {
                        Image(systemName: item.icon)
                            .font(.subheadline)
                            .foregroundStyle(Color("AppPrimary"))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color("AppPrimary").opacity(0.18))
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.value)
                                .font(.headline.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(item.label)
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .glassCard(cornerRadius: 14, elevation: .flat)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct CustomSegmentedControl<T: Hashable & CaseIterable & RawRepresentable>: View where T.RawValue == String {
    @Binding var selection: T

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(T.allCases), id: \.self) { item in
                let isSelected = selection == item
                Button {
                    HapticManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selection = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.caption.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(SurfacePalette.primaryButtonGradient)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .glassCard(cornerRadius: 14, elevation: .raised)
    }
}

struct SpectrumMiniBars: View {
    let valence: Double
    let energy: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            barRow(label: "V", value: valence)
            barRow(label: "E", value: energy)
        }
    }

    private func barRow(label: String, value: Double) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2.bold())
                .foregroundStyle(Color("AppTextSecondary"))
                .frame(width: 10)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("AppBackground").opacity(0.65))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(4, geo.size.width * value))
                }
            }
            .frame(height: 5)
        }
        .frame(height: 10)
    }
}

struct DepthIconBadge: View {
    let icon: String
    var size: CGFloat = 52
    var tint: Color = Color("AppPrimary")

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.38), tint.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .stroke(tint.opacity(0.3), lineWidth: 1)
                }

            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }
}

struct FloatingActionBar<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [
                        Color("AppBackground").opacity(0),
                        Color("AppBackground").opacity(0.88),
                        Color("AppBackground")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

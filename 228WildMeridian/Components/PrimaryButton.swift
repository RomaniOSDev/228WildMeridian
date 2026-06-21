import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String?
    var style: PrimaryButtonStyle = .filled
    let action: () -> Void

    @State private var isPressed = false

    enum PrimaryButtonStyle {
        case filled
        case outline
    }

    var body: some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(style == .filled ? Color("AppTextPrimary") : Color("AppPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(SurfacePalette.borderGradient, lineWidth: 1.5)
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(SurfacePalette.highlightGradient)
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .modifier(DepthShadowModifier(elevation: style == .filled ? .floating : .flat))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isPressed = false
                    }
                }
        )
    }

    @ViewBuilder
    private var buttonBackground: some View {
        if style == .filled {
            SurfacePalette.primaryButtonGradient
        } else {
            Color.clear
        }
    }
}

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * shakesPerUnit),
                y: 0
            )
        )
    }
}

struct ShakeModifier: ViewModifier {
    @Binding var shake: Bool

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: shake ? 1 : 0))
            .animation(shake ? .default : nil, value: shake)
            .onChange(of: shake) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        shake = false
                    }
                }
            }
    }
}

extension View {
    func shake(_ shake: Binding<Bool>) -> some View {
        modifier(ShakeModifier(shake: shake))
    }
}

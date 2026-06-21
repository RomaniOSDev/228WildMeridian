import SwiftUI

enum AppTabBarMetrics {
    static let fallbackHeight: CGFloat = 92
}

struct TabBarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = AppTabBarMetrics.fallbackHeight

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct TabBarBottomInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var tabBarBottomInset: CGFloat {
        get { self[TabBarBottomInsetKey.self] }
        set { self[TabBarBottomInsetKey.self] = newValue }
    }
}

extension View {
    /// Full-screen background with tab bar bottom inset applied to content only.
    func appTabRootLayout() -> some View {
        modifier(AppTabRootLayoutModifier())
    }

    func measureTabBarHeight() -> some View {
        background {
            GeometryReader { geo in
                Color.clear.preference(key: TabBarHeightPreferenceKey.self, value: geo.size.height)
            }
        }
    }
}

private struct AppTabRootLayoutModifier: ViewModifier {
    @Environment(\.tabBarBottomInset) private var inset

    func body(content: Content) -> some View {
        ZStack {
            AppBackgroundView()
            content.padding(.bottom, inset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

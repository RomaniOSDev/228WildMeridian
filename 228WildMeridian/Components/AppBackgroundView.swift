import SwiftUI
import UIKit

enum AppChromeSetup {
    static func apply() {
        configureNavigationBar()
        configureWindowBackground()
    }

    private static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.isTranslucent = true
    }

    private static func configureWindowBackground() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let background = UIColor(named: "AppBackground")
        windowScene.windows.forEach { window in
            window.backgroundColor = background
        }
    }
}

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("AppBackground"),
                    Color("AppBackground").opacity(0.95),
                    Color("AppSurface").opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color("AppPrimary").opacity(0.18), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 220
                            )
                        )
                        .frame(width: 320, height: 320)
                        .offset(x: -90, y: -220)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color("AppAccent").opacity(0.12), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 160
                            )
                        )
                        .frame(width: 280, height: 280)
                        .offset(x: 110, y: 260)

                    Ellipse()
                        .fill(Color("AppSurface").opacity(0.08))
                        .frame(width: geo.size.width * 0.95, height: 180)
                        .rotationEffect(.degrees(-12))
                        .offset(y: 100)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

extension View {
    func withAppBackground() -> some View {
        ZStack {
            AppBackgroundView()
            self
        }
    }

    func appScreenBackground() -> some View {
        background {
            AppBackgroundView()
        }
    }

    func appNavigationStyle(
        titleDisplayMode: NavigationBarItem.TitleDisplayMode = .large
    ) -> some View {
        modifier(AppNavigationStyleModifier(titleDisplayMode: titleDisplayMode))
    }

    func appScrollStyle() -> some View {
        scrollContentBackground(.hidden)
    }
}

private struct AppNavigationStyleModifier: ViewModifier {
    let titleDisplayMode: NavigationBarItem.TitleDisplayMode

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .navigationBarTitleDisplayMode(titleDisplayMode)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        } else {
            content
                .navigationBarTitleDisplayMode(titleDisplayMode)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

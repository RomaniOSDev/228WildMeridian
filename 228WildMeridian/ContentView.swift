import SwiftUI

struct ContentView: View {
    @StateObject private var appStorage = AppStorage.shared

    var body: some View {
        Group {
            if appStorage.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(appStorage)
        .preferredColorScheme(.dark)
        .onAppear {
            AppChromeSetup.apply()
        }
    }
}

#Preview {
    ContentView()
}

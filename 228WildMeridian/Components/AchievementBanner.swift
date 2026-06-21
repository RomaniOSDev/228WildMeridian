import SwiftUI

struct AchievementBannerView: View {
    let achievement: AchievementDefinition
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -120

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color("AppPrimary").opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundStyle(Color("AppAccent"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }

            Spacer()
        }
        .padding(16)
        .glassCard(cornerRadius: 16, elevation: .floating)
        .padding(.horizontal, 16)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offset = -120
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onDismiss()
                }
            }
        }
    }
}

struct AchievementBannerContainer: View {
    @EnvironmentObject private var appStorage: AppStorage

    var body: some View {
        VStack {
            if let achievement = appStorage.pendingAchievementBanner {
                AchievementBannerView(achievement: achievement) {
                    appStorage.dismissAchievementBanner()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.3), value: appStorage.pendingAchievementBanner?.id)
        .allowsHitTesting(appStorage.pendingAchievementBanner != nil)
    }
}

import SwiftUI

enum AppTab: Int, CaseIterable {
    case home
    case emotionLog
    case journal
    case insights
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .emotionLog: return "Emotions"
        case .journal: return "Journal"
        case .insights: return "Insights"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .emotionLog: return "heart.text.square.fill"
        case .journal: return "music.note.list"
        case .insights: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appStorage: AppStorage
    @State private var selectedTab: AppTab = .home
    @State private var tabBarHeight = AppTabBarMetrics.fallbackHeight

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackgroundView()

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environment(\.tabBarBottomInset, tabBarHeight)

            CustomTabBar(selectedTab: $selectedTab)
                .measureTabBarHeight()

            AchievementBannerContainer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground").ignoresSafeArea())
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { height in
            tabBarHeight = height
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView(selectedTab: $selectedTab, appStorage: appStorage)
        case .emotionLog:
            EmotionLogView()
        case .journal:
            JournalContainerView()
        case .insights:
            InsightsHomeView()
        case .settings:
            SettingsView()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(
            DepthSurface(cornerRadius: 22, bordered: true, elevation: .floating)
        )
        .depthShadow(.floating)
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            HapticManager.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(SurfacePalette.primaryButtonGradient)
                            .frame(width: 36, height: 28)
                    }

                    Image(systemName: tab.iconName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                }
                .frame(height: 28)

                Text(tab.title)
                    .font(.system(size: 9, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isSelected ? 1 : 0.94)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

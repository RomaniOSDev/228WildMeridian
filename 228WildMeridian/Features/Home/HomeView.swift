import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appStorage: AppStorage
    @Binding var selectedTab: AppTab
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var vaultViewModel: InspirationalVaultViewModel

    init(selectedTab: Binding<AppTab>, appStorage: AppStorage) {
        _selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: HomeViewModel(appStorage: appStorage))
        _vaultViewModel = StateObject(wrappedValue: InspirationalVaultViewModel(appStorage: appStorage))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 18) {
                        HomeHeroWidget(
                            greeting: viewModel.greeting,
                            streakDays: appStorage.streakDays,
                            hasActivityToday: viewModel.hasActivityToday
                        )

                        HomeStatsWidgetRow(
                            entries: viewModel.totalEntries,
                            minutes: appStorage.totalMinutesUsed,
                            activeDays: MusicAnalyticsService.activeDaysThisMonth(appStorage: appStorage)
                        )

                        HomeQuickActionsWidget(
                            onLogEmotion: { selectedTab = .emotionLog },
                            onNewReflection: { selectedTab = .journal },
                            onStartSession: { viewModel.showReflectionSession = true },
                            onOpenInsights: { selectedTab = .insights }
                        )

                        HStack(spacing: 12) {
                            NavigationLink {
                                MoodInsightsView(appStorage: appStorage)
                            } label: {
                                HomeMoodWidget(
                                    moodLabel: viewModel.averageMoodLabel,
                                    topEmotion: viewModel.topEmotionThisWeek
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        NavigationLink {
                            ReflectionSessionView(appStorage: appStorage)
                        } label: {
                            HomeSessionWidget(totalMinutes: appStorage.totalMinutesUsed)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded {
                            HapticManager.lightTap()
                        })

                        HomeOnThisDayWidget(items: viewModel.onThisDayItems)

                        if let song = viewModel.featuredSong {
                            HomeFeaturedWidget(
                                song: song,
                                isFavorite: vaultViewModel.isFavorite(song)
                            ) {
                                vaultViewModel.selectedSong = song
                            }
                        }

                        HomeRecentActivityWidget(
                            items: viewModel.recentItems,
                            appStorage: appStorage
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .appScrollStyle()
            }
            .appTabRootLayout()
            .navigationTitle("Home")
            .appNavigationStyle()
            .navigationDestination(isPresented: $viewModel.showReflectionSession) {
                ReflectionSessionView(appStorage: appStorage)
            }
            .sheet(item: $vaultViewModel.selectedSong) { song in
                InspirationDetailView(song: song, viewModel: vaultViewModel)
            }
        }
    }
}

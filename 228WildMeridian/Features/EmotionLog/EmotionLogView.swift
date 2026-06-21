import SwiftUI

struct EmotionLogView: View {
    @EnvironmentObject private var appStorage: AppStorage

    var body: some View {
        EmotionLogContent(appStorage: appStorage)
    }
}

private struct EmotionLogContent: View {
    @ObservedObject var appStorage: AppStorage
    @StateObject private var viewModel: EmotionLogViewModel

    init(appStorage: AppStorage) {
        self.appStorage = appStorage
        _viewModel = StateObject(wrappedValue: EmotionLogViewModel(appStorage: appStorage))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ZStack {
                    VStack(spacing: 0) {
                        if viewModel.isEmpty {
                            ScrollView {
                                emptyState
                                    .padding(.top, 40)
                            }
                            .appScrollStyle()
                        } else {
                            ScrollView {
                                VStack(spacing: 16) {
                                    statsStrip
                                    SearchBarView(text: $viewModel.searchText, placeholder: "Search songs or emotions")

                                    if !viewModel.hasFilteredResults {
                                        EmptyStateView(
                                            icon: "magnifyingglass",
                                            title: "No matches",
                                            message: "Try a different song title or emotion keyword."
                                        )
                                    } else {
                                        LazyVStack(spacing: 12) {
                                            ForEach(viewModel.entries) { entry in
                                                NavigationLink {
                                                    SongTimelineView(songTitle: entry.songTitle, appStorage: appStorage)
                                                } label: {
                                                    EmotionEntryCell(entry: entry)
                                                }
                                                .buttonStyle(.plain)
                                                .rowPulse(viewModel.pulsingEntryID == entry.id)
                                                .contextMenu {
                                                    Button(role: .destructive) {
                                                        viewModel.deleteEntry(id: entry.id)
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                .padding(.bottom, 16)
                            }
                            .appScrollStyle()
                        }

                        FloatingActionBar {
                            PrimaryButton(title: "New Entry", icon: "plus.circle.fill") {
                                viewModel.showNewEntry = true
                            }
                        }
                    }

                    SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessOverlay)
                }
            }
            .appTabRootLayout()
            .navigationTitle("Emotion Log")
            .appNavigationStyle()
            .navigationDestination(isPresented: $viewModel.showNewEntry) {
                EmotionEntryFormView(viewModel: viewModel)
            }
        }
    }

    private var statsStrip: some View {
        ScreenStatsStrip(items: [
            (value: "\(appStorage.emotionEntries.count)", label: "Total logs", icon: "heart.text.square"),
            (value: "\(MusicAnalyticsService.topEmotions(period: .week, appStorage: appStorage).first?.emotion ?? "—")", label: "Top mood", icon: "face.smiling"),
            (value: "\(appStorage.streakDays)d", label: "Streak", icon: "flame.fill")
        ])
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "heart.text.square",
            title: "Your emotion journal",
            message: "Log your first emotional reaction to music!",
            usesEmoji: true,
            emoji: "😌"
        )
    }
}

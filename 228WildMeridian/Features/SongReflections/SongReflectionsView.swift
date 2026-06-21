import SwiftUI

struct SongReflectionsView: View {
    @EnvironmentObject private var appStorage: AppStorage

    var body: some View {
        SongReflectionsContent(appStorage: appStorage)
    }
}

private struct SongReflectionsContent: View {
    @ObservedObject var appStorage: AppStorage
    @StateObject private var viewModel: SongReflectionsViewModel

    init(appStorage: AppStorage) {
        self.appStorage = appStorage
        _viewModel = StateObject(wrappedValue: SongReflectionsViewModel(appStorage: appStorage))
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
                                    SearchBarView(text: $viewModel.searchText, placeholder: "Search reflections")

                                    if !viewModel.hasFilteredResults {
                                        EmptyStateView(
                                            icon: "magnifyingglass",
                                            title: "No matches",
                                            message: "Try another song title or keyword from your journal."
                                        )
                                    } else {
                                        LazyVStack(spacing: 12) {
                                            ForEach(viewModel.entries) { entry in
                                                NavigationLink {
                                                    SongTimelineView(songTitle: entry.songTitle, appStorage: appStorage)
                                                } label: {
                                                    ReflectionEntryCell(
                                                        entry: entry,
                                                        isExpanded: viewModel.expandedEntryID == entry.id
                                                    )
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
                            PrimaryButton(title: "New Entry", icon: "square.and.pencil") {
                                viewModel.showNewEntry = true
                            }
                        }
                    }

                    SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessOverlay)
                }
            }
            .appScreenBackground()
            .navigationTitle("Song Reflections")
            .appNavigationStyle()
            .navigationDestination(isPresented: $viewModel.showNewEntry) {
                ReflectionFormView(viewModel: viewModel)
            }
        }
    }

    private var statsStrip: some View {
        ScreenStatsStrip(items: [
            (value: "\(appStorage.reflections.count)", label: "Reflections", icon: "text.book.closed"),
            (value: "\(MusicAnalyticsService.uniqueSongs(appStorage: appStorage).count)", label: "Songs", icon: "music.note.list"),
            (value: "\(MusicAnalyticsService.activeDaysThisMonth(appStorage: appStorage))", label: "Active days", icon: "calendar")
        ])
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "music.note.list",
            title: "Start journaling",
            message: "Start journaling your musical journey"
        )
    }
}

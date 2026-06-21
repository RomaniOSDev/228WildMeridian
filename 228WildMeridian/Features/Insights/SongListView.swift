import SwiftUI

struct SongListView: View {
    @ObservedObject var appStorage: AppStorage
    @State private var searchText = ""

    private var songs: [String] {
        MusicAnalyticsService.uniqueSongs(appStorage: appStorage)
    }

    private var filteredSongs: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return songs }
        return songs.filter { $0.lowercased().contains(query) }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                if songs.isEmpty {
                    EmptyStateView(
                        icon: "timeline.selection",
                        title: "No timelines yet",
                        message: "Add emotion logs or reflections to build song timelines."
                    )
                    .padding(.top, 60)
                } else {
                    SearchBarView(text: $searchText, placeholder: "Search songs")

                    LazyVStack(spacing: 12) {
                        ForEach(filteredSongs, id: \.self) { song in
                            NavigationLink {
                                SongTimelineView(songTitle: song, appStorage: appStorage)
                            } label: {
                                SongListCell(
                                    songTitle: song,
                                    entryCount: MusicAnalyticsService.entryCount(for: song, appStorage: appStorage),
                                    latestDate: MusicAnalyticsService.timelineItems(for: song, appStorage: appStorage).first?.date
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 40)
        }
        .appScrollStyle()
        }
        .appScreenBackground()
        .navigationTitle("Song Timelines")
        .appNavigationStyle(titleDisplayMode: .inline)
    }
}

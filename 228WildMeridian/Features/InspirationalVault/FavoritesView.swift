import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: InspirationalVaultViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            ScrollView {
                if viewModel.favoriteSongs.isEmpty {
                    EmptyStateView(
                        icon: "heart.slash",
                        title: "No favorites yet",
                        message: "Tap the heart on any inspiration to save it here."
                    )
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.favoriteSongs) { song in
                            InspirationGridCell(
                                song: song,
                                isFavorite: true
                            ) {
                                viewModel.selectedSong = song
                            } onFavoriteTap: {
                                viewModel.toggleFavorite(song)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .appScrollStyle()
        }
        .appScreenBackground()
        .navigationTitle("Favorites")
        .appNavigationStyle(titleDisplayMode: .inline)
        .sheet(item: $viewModel.selectedSong) { song in
            InspirationDetailView(song: song, viewModel: viewModel)
        }
    }
}

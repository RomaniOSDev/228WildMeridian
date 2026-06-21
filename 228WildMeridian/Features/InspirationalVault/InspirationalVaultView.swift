import SwiftUI

struct InspirationalVaultView: View {
    @EnvironmentObject private var appStorage: AppStorage

    var body: some View {
        InspirationalVaultContent(appStorage: appStorage)
    }
}

private struct InspirationalVaultContent: View {
    @ObservedObject var appStorage: AppStorage
    @StateObject private var viewModel: InspirationalVaultViewModel
    @State private var searchText = ""

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    init(appStorage: AppStorage) {
        self.appStorage = appStorage
        _viewModel = StateObject(wrappedValue: InspirationalVaultViewModel(appStorage: appStorage))
    }

    private var filteredCatalog: [InspirationSong] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return viewModel.catalog }
        return viewModel.catalog.filter {
            $0.title.lowercased().contains(query) || $0.artist.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ZStack {
                    ScrollView {
                    VStack(spacing: 16) {
                        if !viewModel.hasFavorites {
                            hintBanner
                        } else {
                            favoritesBanner
                        }

                        SearchBarView(text: $searchText, placeholder: "Search inspirations")

                        if filteredCatalog.isEmpty {
                            EmptyStateView(
                                icon: "magnifyingglass",
                                title: "No inspirations found",
                                message: "Try another artist or song title."
                            )
                        } else {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(filteredCatalog) { song in
                                    InspirationGridCell(
                                        song: song,
                                        isFavorite: viewModel.isFavorite(song)
                                    ) {
                                        viewModel.selectedSong = song
                                    } onFavoriteTap: {
                                        viewModel.toggleFavorite(song)
                                    }
                                    .rowPulse(viewModel.pulsingSongID == song.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .appScrollStyle()

                VStack {
                    Spacer()
                    FloatingActionBar {
                        PrimaryButton(title: "View Favorites", icon: "heart.fill") {
                            if viewModel.hasFavorites {
                                viewModel.showFavorites = true
                            }
                        }
                        .opacity(viewModel.hasFavorites ? 1 : 0.45)
                        .disabled(!viewModel.hasFavorites)
                    }
                }

                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessOverlay)
                }
            }
            .appScreenBackground()
            .navigationTitle("Inspirational Vault")
            .appNavigationStyle()
            .onAppear {
                viewModel.openCatalog()
            }
            .sheet(item: $viewModel.selectedSong) { song in
                InspirationDetailView(song: song, viewModel: viewModel)
            }
            .navigationDestination(isPresented: $viewModel.showFavorites) {
                FavoritesView(viewModel: viewModel)
            }
        }
    }

    private var hintBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.title2)
                .foregroundStyle(Color("AppPrimary"))
            VStack(alignment: .leading, spacing: 4) {
                Text("Discover curated picks")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Start by exploring our curated inspirations!")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
        }
        .padding(16)
        .glassCard(elevation: .raised)
    }

    private var favoritesBanner: some View {
        HStack {
            TagPill(text: "\(viewModel.favoriteSongs.count) favorites saved", icon: "heart.fill")
            Spacer()
        }
    }
}

struct AlbumArtworkView: View {
    let seed: Int

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .stroke(Color("AppTextPrimary").opacity(0.15), lineWidth: 8)
                .frame(width: 56, height: 56)
                .offset(x: -28, y: -18)

            Canvas { context, size in
                let barWidth = size.width * 0.08
                for index in 0..<5 {
                    let x = size.width * 0.2 + CGFloat(index) * barWidth * 1.5
                    let height = size.height * (0.3 + CGFloat((seed + index) % 4) * 0.12)
                    let rect = CGRect(x: x, y: size.height - height - 8, width: barWidth, height: height)
                    context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(Color("AppTextPrimary").opacity(0.35)))
                }
            }
        }
    }

    private var gradientColors: [Color] {
        switch seed % 4 {
        case 0:
            return [Color("AppPrimary"), Color("AppSurface")]
        case 1:
            return [Color("AppAccent"), Color("AppBackground")]
        case 2:
            return [Color("AppSurface"), Color("AppPrimary")]
        default:
            return [Color("AppBackground"), Color("AppAccent")]
        }
    }
}

import SwiftUI

struct InspirationDetailView: View {
    let song: InspirationSong
    @ObservedObject var viewModel: InspirationalVaultViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        AlbumArtworkView(seed: song.artworkSeed)
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color("AppTextPrimary").opacity(0.12), lineWidth: 1)
                            }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(song.title)
                                .font(.title.bold())
                                .foregroundStyle(Color("AppTextPrimary"))

                            Text(song.artist)
                                .font(.headline)
                                .foregroundStyle(Color("AppTextSecondary"))

                            TagPill(text: "Curated inspiration", icon: "sparkles")
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeaderView(title: "Insight", subtitle: "Why this track matters")

                            Text(song.insight)
                                .font(.body)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .glassCard()

                        PrimaryButton(
                            title: viewModel.isFavorite(song) ? "Remove from Favorites" : "Add to Favorites",
                            icon: viewModel.isFavorite(song) ? "heart.slash.fill" : "heart.fill"
                        ) {
                            viewModel.toggleFavorite(song)
                        }
                    }
                    .padding(20)
                }
                .appScrollStyle()
            }
            .appScreenBackground()
            .navigationTitle("Song Insight")
            .appNavigationStyle(titleDisplayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        HapticManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}

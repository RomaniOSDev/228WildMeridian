import Combine
import Foundation
import UIKit

@MainActor
final class InspirationalVaultViewModel: ObservableObject {
    @Published var selectedSong: InspirationSong?
    @Published var showFavorites = false
    @Published var showSuccessOverlay = false
    @Published var pulsingSongID: String?

    private let appStorage: AppStorage

    let catalog = InspirationCatalog.songs

    init(appStorage: AppStorage) {
        self.appStorage = appStorage
    }

    var hasFavorites: Bool {
        !appStorage.favorites.isEmpty
    }

    var favoriteSongs: [InspirationSong] {
        catalog.filter { appStorage.isFavorite(songID: $0.id) }
    }

    func isFavorite(_ song: InspirationSong) -> Bool {
        appStorage.isFavorite(songID: song.id)
    }

    func toggleFavorite(_ song: InspirationSong) {
        let added = appStorage.toggleFavorite(songID: song.id, songTitle: song.title)
        if added {
            HapticManager.saveFeedback(style: .light)
            HapticManager.successNotification()
            pulsingSongID = song.id
            showSuccessOverlay = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.pulsingSongID = nil
            }
        } else {
            HapticManager.lightTap()
        }
    }

    func openCatalog() {
        appStorage.lastViewedDate = Date()
    }
}

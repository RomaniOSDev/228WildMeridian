import Combine
import Foundation
import UIKit

@MainActor
final class EmotionLogViewModel: ObservableObject {
    @Published var showNewEntry = false
    @Published var showSuccessOverlay = false
    @Published var pulsingEntryID: UUID?
    @Published var searchText = ""

    private let appStorage: AppStorage

    init(appStorage: AppStorage) {
        self.appStorage = appStorage
    }

    var entries: [EmotionEntry] {
        let sorted = appStorage.emotionEntries.sorted { $0.createdAt > $1.createdAt }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return sorted }
        return sorted.filter {
            $0.songTitle.lowercased().contains(query)
                || $0.description.lowercased().contains(query)
                || $0.emotion.contains(query)
        }
    }

    var isEmpty: Bool {
        appStorage.emotionEntries.isEmpty
    }

    var hasFilteredResults: Bool {
        !entries.isEmpty
    }

    func deleteEntry(id: UUID) {
        HapticManager.lightTap()
        appStorage.deleteEmotionEntry(id: id)
    }

    func saveEntry(
        songTitle: String,
        description: String,
        emotion: String,
        valence: Double,
        energy: Double
    ) -> Bool {
        let trimmedTitle = songTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty, !trimmedDescription.isEmpty else {
            return false
        }

        let entry = EmotionEntry(
            songTitle: trimmedTitle,
            description: trimmedDescription,
            emotion: emotion,
            valence: valence,
            energy: energy
        )

        appStorage.addEmotionEntry(entry)
        HapticManager.saveFeedback(style: .light)
        HapticManager.successNotification()

        pulsingEntryID = entry.id
        showSuccessOverlay = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.pulsingEntryID = nil
        }

        return true
    }
}

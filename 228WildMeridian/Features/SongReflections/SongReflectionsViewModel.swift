import Combine
import Foundation
import UIKit

@MainActor
final class SongReflectionsViewModel: ObservableObject {
    @Published var showNewEntry = false
    @Published var showSuccessOverlay = false
    @Published var pulsingEntryID: UUID?
    @Published var expandedEntryID: UUID?
    @Published var searchText = ""

    private let appStorage: AppStorage

    init(appStorage: AppStorage) {
        self.appStorage = appStorage
    }

    var entries: [Reflection] {
        let sorted = appStorage.reflections.sorted { $0.date > $1.date }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return sorted }
        return sorted.filter {
            $0.songTitle.lowercased().contains(query) || $0.text.lowercased().contains(query)
        }
    }

    var isEmpty: Bool {
        appStorage.reflections.isEmpty
    }

    var hasFilteredResults: Bool {
        !entries.isEmpty
    }

    func deleteEntry(id: UUID) {
        HapticManager.lightTap()
        appStorage.deleteReflection(id: id)
    }

    func saveEntry(songTitle: String, text: String, date: Date) -> Bool {
        let trimmedTitle = songTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty, !trimmedText.isEmpty else {
            return false
        }

        let reflection = Reflection(
            songTitle: trimmedTitle,
            text: trimmedText,
            date: date
        )

        appStorage.addReflection(reflection)
        HapticManager.saveFeedback(style: .medium)
        HapticManager.successNotification()

        expandedEntryID = reflection.id
        pulsingEntryID = reflection.id
        showSuccessOverlay = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.expandedEntryID = nil
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.pulsingEntryID = nil
        }

        return true
    }
}

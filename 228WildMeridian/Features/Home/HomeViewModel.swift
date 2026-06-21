import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var showReflectionSession = false

    private let appStorage: AppStorage

    init(appStorage: AppStorage) {
        self.appStorage = appStorage
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    var totalEntries: Int {
        appStorage.emotionEntries.count + appStorage.reflections.count
    }

    var recentItems: [TimelineItem] {
        Array(MusicAnalyticsService.allTimelineItems(appStorage: appStorage).prefix(4))
    }

    var onThisDayItems: [TimelineItem] {
        Array(MusicAnalyticsService.onThisDayItems(appStorage: appStorage).prefix(2))
    }

    var topEmotionThisWeek: String? {
        MusicAnalyticsService.topEmotions(period: .week, appStorage: appStorage).first?.emotion
    }

    var averageMoodLabel: String? {
        guard
            let valence = MusicAnalyticsService.averageValence(period: .month, appStorage: appStorage),
            let energy = MusicAnalyticsService.averageEnergy(period: .month, appStorage: appStorage)
        else { return nil }
        return "\(EmotionSpectrum.valenceLabel(valence)) · \(EmotionSpectrum.energyLabel(energy))"
    }

    var featuredSong: InspirationSong? {
        let catalog = InspirationCatalog.songs
        guard !catalog.isEmpty else { return nil }
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return catalog[dayIndex % catalog.count]
    }

    var hasActivityToday: Bool {
        let calendar = Calendar.current
        return MusicAnalyticsService.allTimelineItems(appStorage: appStorage).contains {
            calendar.isDateInToday($0.date)
        }
    }
}

import Foundation

enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case week = "This Week"
    case month = "This Month"
    case all = "All Time"

    var id: String { rawValue }

    func startDate(relativeTo date: Date = Date()) -> Date? {
        let calendar = Calendar.current
        switch self {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: date)
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: date)
        case .all:
            return nil
        }
    }
}

struct EmotionCount: Identifiable {
    let id: String
    let emotion: String
    let count: Int
}

struct SpectrumPoint: Identifiable {
    let id: UUID
    let valence: Double
    let energy: Double
    let date: Date
}

struct MusicAnalyticsService {
    static func normalizedTitle(_ title: String) -> String {
        title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func uniqueSongs(appStorage: AppStorage) -> [String] {
        var map: [String: String] = [:]
        for entry in appStorage.emotionEntries {
            let key = normalizedTitle(entry.songTitle)
            if map[key] == nil { map[key] = entry.songTitle }
        }
        for reflection in appStorage.reflections {
            let key = normalizedTitle(reflection.songTitle)
            if map[key] == nil { map[key] = reflection.songTitle }
        }
        return map.values.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    static func allTimelineItems(appStorage: AppStorage) -> [TimelineItem] {
        let emotions = appStorage.emotionEntries.map(TimelineItem.init)
        let reflections = appStorage.reflections.map(TimelineItem.init)
        return (emotions + reflections).sorted { $0.date > $1.date }
    }

    static func timelineItems(for songTitle: String, appStorage: AppStorage) -> [TimelineItem] {
        let key = normalizedTitle(songTitle)
        return allTimelineItems(appStorage: appStorage)
            .filter { normalizedTitle($0.songTitle) == key }
            .sorted { $0.date > $1.date }
    }

    static func entryCount(for songTitle: String, appStorage: AppStorage) -> Int {
        timelineItems(for: songTitle, appStorage: appStorage).count
    }

    static func items(in period: AnalyticsPeriod, appStorage: AppStorage, referenceDate: Date = Date()) -> [TimelineItem] {
        guard let start = period.startDate(relativeTo: referenceDate) else {
            return allTimelineItems(appStorage: appStorage)
        }
        return allTimelineItems(appStorage: appStorage).filter { $0.date >= start }
    }

    static func topEmotions(period: AnalyticsPeriod, appStorage: AppStorage, limit: Int = 5) -> [EmotionCount] {
        var counts: [String: Int] = [:]
        let start = period.startDate() ?? .distantPast
        for entry in appStorage.emotionEntries where entry.createdAt >= start {
            counts[entry.emotion, default: 0] += 1
        }
        return counts
            .map { EmotionCount(id: $0.key, emotion: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0 }
    }

    static func mostMentionedTrack(period: AnalyticsPeriod, appStorage: AppStorage) -> String? {
        var counts: [String: (display: String, count: Int)] = [:]
        for item in items(in: period, appStorage: appStorage) {
            let key = normalizedTitle(item.songTitle)
            if var existing = counts[key] {
                existing.count += 1
                counts[key] = existing
            } else {
                counts[key] = (item.songTitle, 1)
            }
        }
        return counts.values.max(by: { $0.count < $1.count })?.display
    }

    static func activeDaysThisMonth(appStorage: AppStorage, referenceDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate)) else {
            return 0
        }
        var days = Set<DateComponents>()
        for item in allTimelineItems(appStorage: appStorage) where item.date >= monthStart {
            days.insert(calendar.dateComponents([.year, .month, .day], from: item.date))
        }
        return days.count
    }

    static func onThisDayItems(appStorage: AppStorage, referenceDate: Date = Date()) -> [TimelineItem] {
        let calendar = Calendar.current
        let reference = calendar.dateComponents([.month, .day], from: referenceDate)
        let currentYear = calendar.component(.year, from: referenceDate)

        return allTimelineItems(appStorage: appStorage).filter { item in
            let components = calendar.dateComponents([.year, .month, .day], from: item.date)
            return components.month == reference.month
                && components.day == reference.day
                && components.year != currentYear
        }
    }

    static func spectrumPoints(period: AnalyticsPeriod, appStorage: AppStorage) -> [SpectrumPoint] {
        let start = period.startDate() ?? .distantPast
        return appStorage.emotionEntries
            .filter { $0.createdAt >= start }
            .map { SpectrumPoint(id: $0.id, valence: $0.valence, energy: $0.energy, date: $0.createdAt) }
    }

    static func averageValence(period: AnalyticsPeriod, appStorage: AppStorage) -> Double? {
        let points = spectrumPoints(period: period, appStorage: appStorage)
        guard !points.isEmpty else { return nil }
        return points.map(\.valence).reduce(0, +) / Double(points.count)
    }

    static func averageEnergy(period: AnalyticsPeriod, appStorage: AppStorage) -> Double? {
        let points = spectrumPoints(period: period, appStorage: appStorage)
        guard !points.isEmpty else { return nil }
        return points.map(\.energy).reduce(0, +) / Double(points.count)
    }
}

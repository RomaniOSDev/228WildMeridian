import Combine
import Foundation
import SwiftUI

@MainActor
final class AppStorage: ObservableObject {
    static let shared = AppStorage()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date.timeIntervalSince1970, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var itemsAdded: Int {
        didSet { defaults.set(itemsAdded, forKey: Keys.itemsAdded) }
    }

    @Published var entriesWritten: Int {
        didSet { defaults.set(entriesWritten, forKey: Keys.entriesWritten) }
    }

    @Published var uniqueSongTitles: [String] {
        didSet { saveCodable(uniqueSongTitles, key: Keys.uniqueSongTitles) }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveCodable(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }

    @Published var emotionEntries: [EmotionEntry] {
        didSet {
            saveCodable(emotionEntries, key: Keys.emotionEntries)
            lastAccessed = Date()
        }
    }

    @Published var lastAccessed: Date? {
        didSet {
            if let date = lastAccessed {
                defaults.set(date.timeIntervalSince1970, forKey: Keys.lastAccessed)
            }
        }
    }

    @Published var reflections: [Reflection] {
        didSet {
            saveCodable(reflections, key: Keys.reflections)
            lastOpenedTimestamp = Date()
        }
    }

    @Published var lastOpenedTimestamp: Date? {
        didSet {
            if let date = lastOpenedTimestamp {
                defaults.set(date.timeIntervalSince1970, forKey: Keys.lastOpenedTimestamp)
            }
        }
    }

    @Published var favorites: [String] {
        didSet {
            saveCodable(favorites, key: Keys.favorites)
            totalFavoritesCount = favorites.count
        }
    }

    @Published var lastViewedDate: Date? {
        didSet {
            if let date = lastViewedDate {
                defaults.set(date.timeIntervalSince1970, forKey: Keys.lastViewedDate)
            }
        }
    }

    @Published var totalFavoritesCount: Int {
        didSet { defaults.set(totalFavoritesCount, forKey: Keys.totalFavoritesCount) }
    }

    @Published var pendingAchievementBanner: AchievementDefinition?
    private var achievementBannerQueue: [AchievementDefinition] = []

    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let itemsAdded = "itemsAdded"
        static let entriesWritten = "entriesWritten"
        static let uniqueSongTitles = "uniqueSongTitles"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let emotionEntries = "emotionEntries"
        static let lastAccessed = "lastAccessed"
        static let reflections = "reflections"
        static let lastOpenedTimestamp = "lastOpenedTimestamp"
        static let favorites = "favorites"
        static let lastViewedDate = "lastViewedDate"
        static let totalFavoritesCount = "totalFavoritesCount"
    }

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        itemsAdded = defaults.integer(forKey: Keys.itemsAdded)
        entriesWritten = defaults.integer(forKey: Keys.entriesWritten)
        totalFavoritesCount = defaults.integer(forKey: Keys.totalFavoritesCount)

        if defaults.object(forKey: Keys.lastActivityDate) != nil {
            lastActivityDate = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastActivityDate))
        } else {
            lastActivityDate = nil
        }

        if defaults.object(forKey: Keys.lastAccessed) != nil {
            lastAccessed = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastAccessed))
        } else {
            lastAccessed = nil
        }

        if defaults.object(forKey: Keys.lastOpenedTimestamp) != nil {
            lastOpenedTimestamp = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastOpenedTimestamp))
        } else {
            lastOpenedTimestamp = nil
        }

        if defaults.object(forKey: Keys.lastViewedDate) != nil {
            lastViewedDate = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastViewedDate))
        } else {
            lastViewedDate = nil
        }

        uniqueSongTitles = Self.loadCodable([String].self, key: Keys.uniqueSongTitles, defaults: defaults) ?? []
        achievementsUnlocked = Self.loadCodable([String: Date].self, key: Keys.achievementsUnlocked, defaults: defaults) ?? [:]
        emotionEntries = Self.loadCodable([EmotionEntry].self, key: Keys.emotionEntries, defaults: defaults) ?? []
        reflections = Self.loadCodable([Reflection].self, key: Keys.reflections, defaults: defaults) ?? []
        favorites = Self.loadCodable([String].self, key: Keys.favorites, defaults: defaults) ?? []

        NotificationCenter.default.publisher(for: .dataReset)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordSession(minutes: 1)
    }

    func addEmotionEntry(_ entry: EmotionEntry) {
        emotionEntries.insert(entry, at: 0)
        registerItem(songTitle: entry.songTitle, countsAsEntry: true)
    }

    func deleteEmotionEntry(id: UUID) {
        emotionEntries.removeAll { $0.id == id }
    }

    func addReflection(_ reflection: Reflection) {
        reflections.insert(reflection, at: 0)
        registerItem(songTitle: reflection.songTitle, countsAsEntry: true)
    }

    func deleteReflection(id: UUID) {
        reflections.removeAll { $0.id == id }
    }

    func toggleFavorite(songID: String, songTitle: String) -> Bool {
        lastViewedDate = Date()
        if favorites.contains(songID) {
            favorites.removeAll { $0 == songID }
            return false
        } else {
            favorites.append(songID)
            registerItem(songTitle: songTitle, countsAsEntry: false)
            return true
        }
    }

    func isFavorite(songID: String) -> Bool {
        favorites.contains(songID)
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        achievementsUnlocked[id] != nil
    }

    func dismissAchievementBanner() {
        pendingAchievementBanner = nil
        if !achievementBannerQueue.isEmpty {
            let next = achievementBannerQueue.removeFirst()
            pendingAchievementBanner = next
        }
    }

    func completeReflectionSession(durationMinutes: Int) {
        recordSession(minutes: max(1, durationMinutes))
        evaluateAchievements()
    }

    private func registerItem(songTitle: String, countsAsEntry: Bool) {
        itemsAdded += 1
        if countsAsEntry {
            entriesWritten += 1
        }

        let normalized = songTitle.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !normalized.isEmpty, !uniqueSongTitles.contains(normalized) {
            uniqueSongTitles.append(normalized)
        }

        recordSession(minutes: 2)
        evaluateAchievements()
    }

    private func recordSession(minutes: Int) {
        totalSessionsCompleted += 1
        totalMinutesUsed += minutes
        updateStreak()
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if lastDay == today {
                lastActivityDate = Date()
                return
            }

            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 1 {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActivityDate = Date()
    }

    private func evaluateAchievements() {
        var newlyUnlocked: [AchievementDefinition] = []

        for achievement in AchievementDefinition.all {
            guard achievementsUnlocked[achievement.id] == nil else { continue }
            if meetsCondition(for: achievement) {
                achievementsUnlocked[achievement.id] = Date()
                newlyUnlocked.append(achievement)
            }
        }

        guard !newlyUnlocked.isEmpty else { return }

        for achievement in newlyUnlocked {
            HapticManager.achievementUnlocked()
        }

        if pendingAchievementBanner == nil {
            pendingAchievementBanner = newlyUnlocked.first
            if newlyUnlocked.count > 1 {
                achievementBannerQueue.append(contentsOf: newlyUnlocked.dropFirst())
            }
        } else {
            achievementBannerQueue.append(contentsOf: newlyUnlocked)
        }
    }

    private func meetsCondition(for achievement: AchievementDefinition) -> Bool {
        switch achievement.id {
        case "first_note":
            return itemsAdded >= 1
        case "explorer":
            return itemsAdded >= 10
        case "storyteller":
            return entriesWritten >= 50
        case "inspiration_hunter":
            return itemsAdded >= 20
        case "power_user":
            return itemsAdded >= 50
        case "active_user":
            return entriesWritten >= 10
        case "three_day_streak":
            return streakDays >= 3
        case "week_long_habit":
            return streakDays >= 7
        default:
            return false
        }
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        itemsAdded = defaults.integer(forKey: Keys.itemsAdded)
        entriesWritten = defaults.integer(forKey: Keys.entriesWritten)
        totalFavoritesCount = defaults.integer(forKey: Keys.totalFavoritesCount)

        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) != nil
            ? Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastActivityDate))
            : nil
        lastAccessed = defaults.object(forKey: Keys.lastAccessed) != nil
            ? Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastAccessed))
            : nil
        lastOpenedTimestamp = defaults.object(forKey: Keys.lastOpenedTimestamp) != nil
            ? Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastOpenedTimestamp))
            : nil
        lastViewedDate = defaults.object(forKey: Keys.lastViewedDate) != nil
            ? Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastViewedDate))
            : nil

        uniqueSongTitles = Self.loadCodable([String].self, key: Keys.uniqueSongTitles, defaults: defaults) ?? []
        achievementsUnlocked = Self.loadCodable([String: Date].self, key: Keys.achievementsUnlocked, defaults: defaults) ?? [:]
        emotionEntries = Self.loadCodable([EmotionEntry].self, key: Keys.emotionEntries, defaults: defaults) ?? []
        reflections = Self.loadCodable([Reflection].self, key: Keys.reflections, defaults: defaults) ?? []
        favorites = Self.loadCodable([String].self, key: Keys.favorites, defaults: defaults) ?? []
        pendingAchievementBanner = nil
        achievementBannerQueue.removeAll()
    }

    private func saveCodable<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadCodable<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

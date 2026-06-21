import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_note",
            title: "First Note",
            description: "Added your first music inspiration note.",
            iconName: "music.note"
        ),
        AchievementDefinition(
            id: "explorer",
            title: "Explorer",
            description: "Logged notes on ten different songs.",
            iconName: "map"
        ),
        AchievementDefinition(
            id: "storyteller",
            title: "Storyteller",
            description: "Captured emotions in fifty entries.",
            iconName: "text.book.closed"
        ),
        AchievementDefinition(
            id: "inspiration_hunter",
            title: "Inspiration Hunter",
            description: "Added new inspirations for twenty tracks.",
            iconName: "sparkles"
        ),
        AchievementDefinition(
            id: "power_user",
            title: "Power User",
            description: "Reached 50 items.",
            iconName: "bolt.fill"
        ),
        AchievementDefinition(
            id: "active_user",
            title: "Active User",
            description: "Completed 10 sessions.",
            iconName: "figure.walk"
        ),
        AchievementDefinition(
            id: "three_day_streak",
            title: "Three-Day Streak",
            description: "Used the app 3 days in a row.",
            iconName: "flame"
        ),
        AchievementDefinition(
            id: "week_long_habit",
            title: "Week-Long Habit",
            description: "Used the app 7 days in a row.",
            iconName: "calendar"
        )
    ]
}

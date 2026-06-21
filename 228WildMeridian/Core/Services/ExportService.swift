import Foundation

enum ExportService {
    static func monthlyMarkdown(appStorage: AppStorage, month: Date = Date()) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthTitle = formatter.string(from: month)

        guard
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart)
        else {
            return "# My Music Reflection — \(monthTitle)\n\nNo entries."
        }

        let dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .medium

        let emotions = appStorage.emotionEntries
            .filter { $0.createdAt >= monthStart && $0.createdAt < nextMonth }
            .sorted { $0.createdAt > $1.createdAt }

        let reflections = appStorage.reflections
            .filter { $0.date >= monthStart && $0.date < nextMonth }
            .sorted { $0.date > $1.date }

        var lines: [String] = [
            "# My Music Reflection — \(monthTitle)",
            "",
            "Generated locally. No data leaves your device.",
            "",
            "## Summary",
            "- Total entries: \(emotions.count + reflections.count)",
            "- Day streak: \(appStorage.streakDays)",
            "- Reflection minutes: \(appStorage.totalMinutesUsed)",
            ""
        ]

        if !emotions.isEmpty {
            lines.append("## Emotion Log")
            lines.append("")
            for entry in emotions {
                lines.append(
                    "- **\(entry.songTitle)** (\(dayFormatter.string(from: entry.createdAt))): \(entry.emotion) — \(entry.description)"
                )
                lines.append(
                    "  - Spectrum: \(EmotionSpectrum.valenceLabel(entry.valence)) / \(EmotionSpectrum.energyLabel(entry.energy))"
                )
            }
            lines.append("")
        }

        if !reflections.isEmpty {
            lines.append("## Song Reflections")
            lines.append("")
            for reflection in reflections {
                lines.append(
                    "- **\(reflection.songTitle)** (\(dayFormatter.string(from: reflection.date))): \(reflection.text)"
                )
            }
            lines.append("")
        }

        if emotions.isEmpty && reflections.isEmpty {
            lines.append("No entries recorded this month.")
        }

        return lines.joined(separator: "\n")
    }
}

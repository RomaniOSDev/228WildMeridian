import Foundation

enum TimelineEntryKind: String, Codable {
    case emotion
    case reflection
}

struct TimelineItem: Identifiable, Equatable {
    let id: UUID
    let songTitle: String
    let date: Date
    let kind: TimelineEntryKind
    let preview: String
    let emotion: String?
    let valence: Double?
    let energy: Double?

    init(from entry: EmotionEntry) {
        id = entry.id
        songTitle = entry.songTitle
        date = entry.createdAt
        kind = .emotion
        preview = entry.description
        emotion = entry.emotion
        valence = entry.valence
        energy = entry.energy
    }

    init(from reflection: Reflection) {
        id = reflection.id
        songTitle = reflection.songTitle
        date = reflection.date
        kind = .reflection
        preview = reflection.text
        emotion = nil
        valence = nil
        energy = nil
    }

    var kindLabel: String {
        switch kind {
        case .emotion: return "Emotion Log"
        case .reflection: return "Reflection"
        }
    }

    var yearsAgo: Int {
        Calendar.current.dateComponents([.year], from: date, to: Date()).year ?? 0
    }
}

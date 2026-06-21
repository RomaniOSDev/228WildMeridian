import Foundation

struct EmotionEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var songTitle: String
    var description: String
    var emotion: String
    var valence: Double
    var energy: Double
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, songTitle, description, emotion, valence, energy, createdAt
    }

    init(
        id: UUID = UUID(),
        songTitle: String,
        description: String,
        emotion: String,
        valence: Double = 0.5,
        energy: Double = 0.5,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.songTitle = songTitle
        self.description = description
        self.emotion = emotion
        self.valence = valence
        self.energy = energy
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        songTitle = try container.decode(String.self, forKey: .songTitle)
        description = try container.decode(String.self, forKey: .description)
        emotion = try container.decode(String.self, forKey: .emotion)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        let preset = EmotionSpectrum.preset(for: emotion)
        valence = try container.decodeIfPresent(Double.self, forKey: .valence) ?? preset.valence
        energy = try container.decodeIfPresent(Double.self, forKey: .energy) ?? preset.energy
    }
}

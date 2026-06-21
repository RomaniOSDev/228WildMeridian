import Foundation

struct Reflection: Identifiable, Codable, Equatable {
    let id: UUID
    var songTitle: String
    var text: String
    var date: Date

    init(
        id: UUID = UUID(),
        songTitle: String,
        text: String,
        date: Date = Date()
    ) {
        self.id = id
        self.songTitle = songTitle
        self.text = text
        self.date = date
    }
}

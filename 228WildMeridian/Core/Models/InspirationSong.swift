import Foundation

struct InspirationSong: Identifiable, Equatable {
    let id: String
    let title: String
    let artist: String
    let insight: String
    let artworkSeed: Int
}

enum InspirationCatalog {
    static let songs: [InspirationSong] = [
        InspirationSong(
            id: "insp_001",
            title: "Midnight Echoes",
            artist: "Luna Rivers",
            insight: "A gentle pulse of synth and voice that mirrors late-night introspection. Many listeners use this track to process quiet emotions after a long day.",
            artworkSeed: 1
        ),
        InspirationSong(
            id: "insp_002",
            title: "Golden Horizon",
            artist: "The Wandering Tides",
            insight: "Warm acoustic layers build toward a hopeful chorus. Ideal for journaling about new beginnings and personal growth.",
            artworkSeed: 2
        ),
        InspirationSong(
            id: "insp_003",
            title: "Rain on Glass",
            artist: "Elara Stone",
            insight: "Minimal piano with ambient textures evokes calm melancholy. Perfect for reflecting on bittersweet memories.",
            artworkSeed: 3
        ),
        InspirationSong(
            id: "insp_004",
            title: "Electric Pulse",
            artist: "Neon District",
            insight: "Driving rhythm and bright melodies energize the spirit. Capture feelings of momentum and creative breakthrough.",
            artworkSeed: 4
        ),
        InspirationSong(
            id: "insp_005",
            title: "Silent Meadow",
            artist: "Willow & Pine",
            insight: "Soft folk harmonies invite stillness and gratitude. A companion for peaceful morning reflection sessions.",
            artworkSeed: 5
        ),
        InspirationSong(
            id: "insp_006",
            title: "City Lights Fade",
            artist: "Metro Soul",
            insight: "Smooth R&B grooves blend nostalgia with forward motion. Explore how urban life shapes your musical taste.",
            artworkSeed: 6
        ),
        InspirationSong(
            id: "insp_007",
            title: "Starlit Waltz",
            artist: "Celeste Quartet",
            insight: "Classical strings meet modern production for a dreamy atmosphere. Write about moments that feel timeless.",
            artworkSeed: 7
        ),
        InspirationSong(
            id: "insp_008",
            title: "Rising Tide",
            artist: "Coastal Hearts",
            insight: "Anthemic indie rock with emotional crescendo. Document the songs that help you overcome challenges.",
            artworkSeed: 8
        ),
        InspirationSong(
            id: "insp_009",
            title: "Whispered Truth",
            artist: "Sage Monroe",
            insight: "Intimate vocal performance over sparse instrumentation. Ideal for honest emotional entries about vulnerability.",
            artworkSeed: 9
        ),
        InspirationSong(
            id: "insp_010",
            title: "Solar Flare",
            artist: "Helios Wave",
            insight: "Uplifting electronic beats spark joy and movement. Log the tracks that lift your mood instantly.",
            artworkSeed: 10
        ),
        InspirationSong(
            id: "insp_011",
            title: "Autumn Leaves",
            artist: "Maple & Moon",
            insight: "Seasonal folk tones evoke change and acceptance. Reflect on transitions in your life through music.",
            artworkSeed: 11
        ),
        InspirationSong(
            id: "insp_012",
            title: "Deep Current",
            artist: "Abyssal Sound",
            insight: "Layered ambient drones create space for deep thought. Best for extended journaling sessions.",
            artworkSeed: 12
        )
    ]
}

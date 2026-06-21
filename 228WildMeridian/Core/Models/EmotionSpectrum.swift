import Foundation

enum EmotionSpectrum {
    static func valenceLabel(_ value: Double) -> String {
        switch value {
        case 0..<0.25: return "Sad"
        case 0.25..<0.45: return "Low"
        case 0.45..<0.55: return "Neutral"
        case 0.55..<0.75: return "Positive"
        default: return "Happy"
        }
    }

    static func energyLabel(_ value: Double) -> String {
        switch value {
        case 0..<0.25: return "Calm"
        case 0.25..<0.45: return "Soft"
        case 0.45..<0.55: return "Balanced"
        case 0.55..<0.75: return "Active"
        default: return "Intense"
        }
    }

    static func preset(for emoji: String) -> (valence: Double, energy: Double) {
        switch emoji {
        case "😊": return (0.82, 0.55)
        case "😢": return (0.15, 0.35)
        case "😌": return (0.72, 0.18)
        case "🔥": return (0.65, 0.92)
        case "💫": return (0.78, 0.48)
        case "😤": return (0.35, 0.88)
        case "🥰": return (0.90, 0.42)
        case "😔": return (0.22, 0.28)
        case "⚡️": return (0.58, 0.95)
        case "🌙": return (0.48, 0.12)
        default: return (0.5, 0.5)
        }
    }

    static func closestEmoji(valence: Double, energy: Double) -> String {
        let presets: [(String, Double, Double)] = [
            ("😊", 0.82, 0.55), ("😢", 0.15, 0.35), ("😌", 0.72, 0.18),
            ("🔥", 0.65, 0.92), ("💫", 0.78, 0.48), ("😤", 0.35, 0.88),
            ("🥰", 0.90, 0.42), ("😔", 0.22, 0.28), ("⚡️", 0.58, 0.95), ("🌙", 0.48, 0.12)
        ]
        var best = "😊"
        var bestDistance = Double.greatestFiniteMagnitude
        for (emoji, v, e) in presets {
            let distance = pow(v - valence, 2) + pow(e - energy, 2)
            if distance < bestDistance {
                bestDistance = distance
                best = emoji
            }
        }
        return best
    }
}

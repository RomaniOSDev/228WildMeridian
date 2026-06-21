import SwiftUI

struct SongTimelineView: View {
    let songTitle: String
    @ObservedObject var appStorage: AppStorage

    private var items: [TimelineItem] {
        MusicAnalyticsService.timelineItems(for: songTitle, appStorage: appStorage)
    }

    private var emotionItems: [TimelineItem] {
        items.filter { $0.kind == .emotion }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                headerSection
                evolutionSection
                timelineSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 40)
        }
        .appScrollStyle()
        }
        .appScreenBackground()
        .navigationTitle(songTitle)
        .appNavigationStyle(titleDisplayMode: .inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TagPill(text: "Song Timeline", icon: "clock.arrow.circlepath")
                Spacer()
                TagPill(text: "\(items.count) moments", tint: Color("AppAccent"))
            }

            Text("How your feelings evolved over time")
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))

            Text("Every emotion log and reflection for this track, chronologically.")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(16)
        .glassCard()
    }

    private var evolutionSection: some View {
        Group {
            if emotionItems.count >= 2 {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeaderView(title: "Emotion Evolution", subtitle: "First vs latest mood")

                    EmotionSpectrumMapView(
                        valence: emotionItems.first?.valence ?? 0.5,
                        energy: emotionItems.first?.energy ?? 0.5,
                        points: emotionItems.compactMap { item in
                            guard let valence = item.valence, let energy = item.energy else { return nil }
                            return SpectrumPoint(id: item.id, valence: valence, energy: energy, date: item.date)
                        }
                    )
                    .frame(height: 160)

                    HStack(spacing: 12) {
                        if let oldest = emotionItems.last, let valence = oldest.valence, let energy = oldest.energy {
                            evolutionChip(title: "First", emoji: oldest.emotion ?? "🎵", valence: valence, energy: energy)
                        }
                        if let newest = emotionItems.first, let valence = newest.valence, let energy = newest.energy {
                            evolutionChip(title: "Latest", emoji: newest.emotion ?? "🎵", valence: valence, energy: energy)
                        }
                    }
                }
                .padding(16)
                .glassCard()
            }
        }
    }

    private func evolutionChip(title: String, emoji: String, valence: Double, energy: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(EmotionSpectrum.valenceLabel(valence))
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(EmotionSpectrum.energyLabel(energy))
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("AppBackground").opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Timeline", subtitle: "Newest first")

            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                TimelineEventCell(item: item, isLast: index == items.count - 1)
            }
        }
    }
}

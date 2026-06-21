import Charts
import SwiftUI

struct MoodInsightsView: View {
    @ObservedObject var appStorage: AppStorage
    @State private var period: AnalyticsPeriod = .month

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                Picker("Period", selection: $period) {
                    ForEach(AnalyticsPeriod.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: period) { _ in HapticManager.lightTap() }

                summaryCards
                topEmotionsChart
                spectrumSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 16)
        }
        .appScrollStyle()
        }
        .appScreenBackground()
        .navigationTitle("Mood Insights")
        .appNavigationStyle(titleDisplayMode: .inline)
    }

    private var summaryCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                StatMetricCell(
                    value: "\(appStorage.streakDays)",
                    label: "Day Streak",
                    icon: "flame.fill",
                    compact: true
                )
                StatMetricCell(
                    value: "\(MusicAnalyticsService.activeDaysThisMonth(appStorage: appStorage))",
                    label: "Active Days",
                    icon: "calendar",
                    compact: true
                )
            }

            if let track = MusicAnalyticsService.mostMentionedTrack(period: period, appStorage: appStorage) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Most Mentioned Track", systemImage: "music.note")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(track)
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .glassCard()
            }

            if let valence = MusicAnalyticsService.averageValence(period: period, appStorage: appStorage),
               let energy = MusicAnalyticsService.averageEnergy(period: period, appStorage: appStorage) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Average Mood")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text("\(EmotionSpectrum.valenceLabel(valence)) · \(EmotionSpectrum.energyLabel(energy))")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    Spacer()
                    SpectrumMiniBars(valence: valence, energy: energy)
                        .frame(width: 100)
                }
                .padding(16)
                .glassCard()
            }
        }
    }

    private var topEmotionsChart: some View {
        let emotions = MusicAnalyticsService.topEmotions(period: period, appStorage: appStorage)

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Top Emotions", subtitle: period.rawValue)

            if emotions.isEmpty {
                EmptyStateView(
                    icon: "chart.bar",
                    title: "No data yet",
                    message: "Log emotions to see trends here."
                )
            } else {
                Chart(emotions) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Emotion", item.emotion)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(6)
                    .annotation(position: .trailing) {
                        Text("\(item.count)")
                            .font(.caption2.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color("AppTextSecondary").opacity(0.25))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
                .frame(height: CGFloat(max(emotions.count, 1)) * 48)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var spectrumSection: some View {
        let points = MusicAnalyticsService.spectrumPoints(period: period, appStorage: appStorage)

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Emotion Spectrum Map", subtitle: "Valence and energy clusters")

            if points.isEmpty {
                EmptyStateView(
                    icon: "circle.grid.cross",
                    title: "Empty map",
                    message: "Your mood map fills in as you log emotional entries."
                )
            } else {
                EmotionSpectrumMapView(
                    valence: 0.5,
                    energy: 0.5,
                    points: points,
                    highlightValence: nil,
                    highlightEnergy: nil
                )
                .frame(height: 190)
            }
        }
        .padding(16)
        .glassCard()
    }
}

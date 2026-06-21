import SwiftUI

struct InsightsHomeView: View {
    @EnvironmentObject private var appStorage: AppStorage

    private var exportMarkdown: String {
        ExportService.monthlyMarkdown(appStorage: appStorage)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        HeroBannerCard(
                            title: "Your music story",
                            subtitle: "Track patterns, timelines, and memories from every song you log.",
                            icon: "waveform.path.ecg"
                        )

                        quickStatsRow
                        OnThisDayCard(appStorage: appStorage)
                        exploreSection
                        sessionSection
                        exportSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 16)
                }
                .appScrollStyle()
            }
            .appTabRootLayout()
            .navigationTitle("Insights")
            .appNavigationStyle()
        }
    }

    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            StatMetricCell(
                value: "\(appStorage.streakDays)",
                label: "Streak",
                icon: "flame.fill",
                compact: true
            )
            StatMetricCell(
                value: "\(MusicAnalyticsService.activeDaysThisMonth(appStorage: appStorage))",
                label: "Active",
                icon: "calendar",
                compact: true
            )
            StatMetricCell(
                value: "\(appStorage.totalMinutesUsed)",
                label: "Minutes",
                icon: "timer",
                compact: true
            )
        }
    }

    private var exploreSection: some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: "Explore", subtitle: "Analytics and song history")

            NavigationLink {
                MoodInsightsView(appStorage: appStorage)
            } label: {
                InsightActionCell(
                    title: "Mood Insights",
                    subtitle: "Top emotions, streaks, and mood map",
                    icon: "chart.bar.fill",
                    badge: "Charts"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                SongListView(appStorage: appStorage)
            } label: {
                InsightActionCell(
                    title: "Song Timelines",
                    subtitle: "See how feelings changed per track",
                    icon: "clock.arrow.circlepath",
                    badge: "\(MusicAnalyticsService.uniqueSongs(appStorage: appStorage).count) songs"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var sessionSection: some View {
        NavigationLink {
            ReflectionSessionView(appStorage: appStorage)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: "headphones.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppTextPrimary"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Reflection Session")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("5 / 10 / 15 min guided listening journal")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                Spacer()

                TagPill(text: "Start", icon: "play.fill")
            }
            .padding(16)
            .heroCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            HapticManager.lightTap()
        })
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Export",
                subtitle: "Share this month's reflections as Markdown"
            )

            ShareLink(item: exportMarkdown) {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Reflection")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Image(systemName: "doc.text")
                        .font(.caption)
                }
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .simultaneousGesture(TapGesture().onEnded {
                HapticManager.lightTap()
            })
        }
        .padding(16)
        .glassCard()
    }
}

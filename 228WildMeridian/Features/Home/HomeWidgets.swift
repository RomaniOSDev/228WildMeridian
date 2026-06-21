import SwiftUI

// MARK: - Hero

struct HomeHeroWidget: View {
    let greeting: String
    let streakDays: Int
    let hasActivityToday: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.1),
                    Color("AppBackground").opacity(0.55),
                    Color("AppBackground").opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    TagPill(text: "\(streakDays) day streak", icon: "flame.fill")
                    if hasActivityToday {
                        TagPill(text: "Active today", icon: "checkmark.circle.fill", tint: Color("AppAccent"))
                    }
                }

                Text(greeting)
                    .font(.title.bold())
                    .foregroundStyle(Color("AppTextPrimary"))

                Text("Your music journal is ready for today's reflections.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
            }
            .padding(18)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(SurfacePalette.borderGradient, lineWidth: 1)
        }
        .depthShadow(.hero)
    }
}

// MARK: - Stats Row

struct HomeStatsWidgetRow: View {
    let entries: Int
    let minutes: Int
    let activeDays: Int

    var body: some View {
        HStack(spacing: 10) {
            HomeMiniStatWidget(value: "\(entries)", label: "Entries", icon: "doc.text.fill")
            HomeMiniStatWidget(value: "\(minutes)", label: "Minutes", icon: "timer")
            HomeMiniStatWidget(value: "\(activeDays)", label: "This month", icon: "calendar")
        }
    }
}

struct HomeMiniStatWidget: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color("AppPrimary"))
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: 16, elevation: .flat)
    }
}

// MARK: - Quick Actions

struct HomeQuickActionsWidget: View {
    let onLogEmotion: () -> Void
    let onNewReflection: () -> Void
    let onStartSession: () -> Void
    let onOpenInsights: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Actions", subtitle: "Jump into your flow")

            LazyVGrid(columns: columns, spacing: 10) {
                HomeActionTile(title: "Log Emotion", icon: "heart.text.square.fill", tint: Color("AppPrimary"), action: onLogEmotion)
                HomeActionTile(title: "Reflection", icon: "square.and.pencil", tint: Color("AppAccent"), action: onNewReflection)
                HomeActionTile(title: "Session", icon: "headphones", tint: Color("AppPrimary"), action: onStartSession)
                HomeActionTile(title: "Insights", icon: "chart.bar.fill", tint: Color("AppAccent"), action: onOpenInsights)
            }
        }
    }
}

struct HomeActionTile: View {
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(width: 44, height: 44)
                    .background(tint.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .glassCard(cornerRadius: 16, elevation: .flat)
            .scaleEffect(pressed ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}

// MARK: - Image Widgets

struct HomeMoodWidget: View {
    let moodLabel: String?
    let topEmotion: String?

    var body: some View {
        HStack(spacing: 0) {
            Image("HomeWidgetMood")
                .resizable()
                .scaledToFill()
                .frame(width: 110)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text("Mood Snapshot")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                if let moodLabel {
                    Text(moodLabel)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppAccent"))
                } else {
                    Text("Log emotions to unlock your mood map.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                if let topEmotion {
                    TagPill(text: "Top this week: \(topEmotion)", icon: "star.fill")
                }

                HStack {
                    Text("View insights")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 130)
        .glassCard(cornerRadius: 18, elevation: .raised)
        .clipped()
    }
}

struct HomeSessionWidget: View {
    let totalMinutes: Int

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Reflection Session")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                Text("\(totalMinutes) min logged so far")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))

                TagPill(text: "5 · 10 · 15 min", icon: "clock")

                HStack {
                    Text("Start now")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Image(systemName: "play.fill")
                        .font(.caption2)
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(.top, 4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)

            Image("HomeWidgetSession")
                .resizable()
                .scaledToFill()
                .frame(width: 110)
                .clipped()
        }
        .frame(height: 130)
        .glassCard(cornerRadius: 18, elevation: .raised)
        .clipped()
    }
}

// MARK: - On This Day

struct HomeOnThisDayWidget: View {
    let items: [TimelineItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "On This Day", subtitle: "Memories from past years")

            if items.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text("Your memory capsule fills in over time.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            } else {
                ForEach(items) { item in
                    OnThisDayMemoryCell(item: item)
                }
            }
        }
        .padding(16)
        .glassCard(elevation: .floating)
    }
}

// MARK: - Recent Activity

struct HomeRecentActivityWidget: View {
    let items: [TimelineItem]
    let appStorage: AppStorage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Recent Activity", subtitle: "Latest emotional moments")

            if items.isEmpty {
                EmptyStateView(
                    icon: "waveform.path",
                    title: "Nothing yet",
                    message: "Your recent entries will appear here."
                )
            } else {
                ForEach(items) { item in
                    NavigationLink {
                        SongTimelineView(songTitle: item.songTitle, appStorage: appStorage)
                    } label: {
                        HomeRecentRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard(elevation: .floating)
    }
}

struct HomeRecentRow: View {
    let item: TimelineItem

    var body: some View {
        HStack(spacing: 12) {
            Text(item.emotion ?? "📝")
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(Color("AppBackground").opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.songTitle)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                Text(item.preview)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
            }

            Spacer()

            Text(item.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Featured Inspiration

struct HomeFeaturedWidget: View {
    let song: InspirationSong
    let isFavorite: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            HapticManager.lightTap()
            onTap()
        } label: {
            HStack(spacing: 14) {
                AlbumArtworkView(seed: song.artworkSeed)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    TagPill(text: "Today's pick", icon: "sparkles")
                    Text(song.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                    Text(song.artist)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    if isFavorite {
                        TagPill(text: "In favorites", icon: "heart.fill", tint: Color("AppPrimary"))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color("AppPrimary"))
            }
            .padding(14)
            .glassCard(cornerRadius: 18, elevation: .raised)
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

struct EmotionEntryCell: View {
    let entry: EmotionEntry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary")],
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 58, height: 58)

                Circle()
                    .fill(Color("AppBackground").opacity(0.85))
                    .frame(width: 50, height: 50)

                Text(entry.emotion)
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.songTitle)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                        .frame(width: 28, height: 28)
                        .background(Color("AppAccent").opacity(0.12))
                        .clipShape(Circle())
                }

                Text(entry.description)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 8) {
                    TagPill(
                        text: EmotionSpectrum.valenceLabel(entry.valence),
                        icon: "face.smiling"
                    )
                    TagPill(
                        text: EmotionSpectrum.energyLabel(entry.energy),
                        icon: "bolt.fill",
                        tint: Color("AppAccent")
                    )
                }

                SpectrumMiniBars(valence: entry.valence, energy: entry.energy)
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .glassCard(elevation: .flat)
    }
}

struct ReflectionEntryCell: View {
    let entry: Reflection
    var isExpanded: Bool = false

    private var wordCount: Int {
        entry.text.split { $0.isWhitespace || $0.isNewline }.count
    }

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .padding(.vertical, 12)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "music.note")
                                .font(.caption)
                                .foregroundStyle(Color("AppPrimary"))
                            Text(entry.songTitle)
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }

                        TagPill(
                            text: entry.date.formatted(date: .abbreviated, time: .omitted),
                            icon: "calendar"
                        )
                    }

                    Spacer()

                    Image(systemName: "quote.opening")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary").opacity(0.35))
                }

                Text(entry.text)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextPrimary").opacity(0.92))
                    .lineLimit(isExpanded ? nil : 3)
                    .lineSpacing(3)

                HStack {
                    TagPill(
                        text: "\(wordCount) words",
                        icon: "text.alignleft",
                        tint: Color("AppTextSecondary")
                    )
                    Spacer()
                    Text("View timeline")
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Image(systemName: "arrow.right")
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 16)
            .padding(.vertical, 14)
        }
        .glassCard(elevation: .flat)
        .scaleEffect(isExpanded ? 1.02 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
    }
}

struct InspirationGridCell: View {
    let song: InspirationSong
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavoriteTap: () -> Void

    @State private var heartScale: CGFloat = 1

    var body: some View {
        Button {
            HapticManager.lightTap()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    AlbumArtworkView(seed: song.artworkSeed)
                        .frame(height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color("AppTextPrimary").opacity(0.12), lineWidth: 1)
                        }

                    TagPill(text: moodTag, icon: "sparkles", tint: Color("AppAccent"))
                        .padding(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)

                    Text(song.artist)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }

                HStack {
                    Label("Insights", systemImage: "info.circle")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    Button {
                        onFavoriteTap()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            heartScale = 1.25
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                heartScale = 1
                            }
                        }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(isFavorite ? Color("AppPrimary") : Color("AppTextSecondary"))
                            .scaleEffect(heartScale)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .glassCard(cornerRadius: 18, elevation: .flat)
        }
        .buttonStyle(.plain)
    }

    private var moodTag: String {
        switch song.artworkSeed % 4 {
        case 0: return "Uplifting"
        case 1: return "Reflective"
        case 2: return "Calm"
        default: return "Energetic"
        }
    }
}

struct SongListCell: View {
    let songTitle: String
    let entryCount: Int
    var latestDate: Date?

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.35), Color("AppSurface")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: "music.quarternote.3")
                    .font(.title3)
                    .foregroundStyle(Color("AppTextPrimary"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(songTitle)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                HStack(spacing: 8) {
                    TagPill(text: "\(entryCount) entries", icon: "clock.arrow.circlepath")
                    if let latestDate {
                        TagPill(
                            text: latestDate.formatted(date: .abbreviated, time: .omitted),
                            tint: Color("AppTextSecondary")
                        )
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(Color("AppAccent"))
        }
        .padding(14)
        .glassCard(cornerRadius: 14, elevation: .flat)
    }
}

struct TimelineEventCell: View {
    let item: TimelineItem
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(item.kind == .emotion ? Color("AppPrimary") : Color("AppAccent"))
                        .frame(width: 14, height: 14)
                    Circle()
                        .stroke(Color("AppTextPrimary").opacity(0.35), lineWidth: 2)
                        .frame(width: 22, height: 22)
                }
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary").opacity(0.5), Color("AppAccent").opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(minHeight: 72)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TagPill(
                        text: item.kindLabel,
                        icon: item.kind == .emotion ? "heart.text.square" : "text.book.closed"
                    )
                    Spacer()
                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                if let emotion = item.emotion {
                    HStack(spacing: 8) {
                        Text(emotion)
                            .font(.title2)
                        if let valence = item.valence, let energy = item.energy {
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
                }

                Text(item.preview)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextPrimary").opacity(0.9))
                    .lineSpacing(2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: 14, elevation: .flat)
        }
    }
}

struct InsightActionCell: View {
    let title: String
    let subtitle: String
    let icon: String
    var badge: String?

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.35), Color("AppPrimary").opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color("AppTextPrimary"))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    if let badge {
                        TagPill(text: badge, tint: Color("AppAccent"))
                    }
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right.circle.fill")
                .font(.title3)
                .foregroundStyle(Color("AppPrimary"))
        }
        .padding(16)
        .glassCard(elevation: .raised)
    }
}

struct OnThisDayMemoryCell: View {
    let item: TimelineItem

    var body: some View {
        HStack(spacing: 12) {
            Text(item.emotion ?? "📝")
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Color("AppBackground").opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.songTitle)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                    Spacer()
                    Text(timeAgoLabel)
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppAccent"))
                }

                Text(item.preview)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)

                TagPill(text: item.kindLabel, tint: Color("AppTextSecondary"))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.55),
                            Color("AppSurface").opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.15), lineWidth: 0.5)
                }
        )
    }

    private var timeAgoLabel: String {
        let years = item.yearsAgo
        if years <= 0 { return item.date.formatted(date: .abbreviated, time: .omitted) }
        return years == 1 ? "1 year ago" : "\(years) years ago"
    }
}

struct StatMetricCell: View {
    let value: String
    let label: String
    let icon: String
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 6 : 10) {
            Image(systemName: icon)
                .font(compact ? .subheadline : .title3)
                .foregroundStyle(Color("AppPrimary"))
                .frame(width: compact ? 32 : 40, height: compact ? 32 : 40)
                .background(Color("AppPrimary").opacity(0.14))
                .clipShape(Circle())

            Text(value)
                .font(compact ? .headline.bold() : .title2.bold())
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(compact ? 12 : 16)
        .glassCard(cornerRadius: 14, elevation: .flat)
    }
}

struct SettingsRowCell: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(isDestructive ? .red : Color("AppPrimary"))
                .frame(width: 36, height: 36)
                .background((isDestructive ? Color.red : Color("AppPrimary")).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.body)
                .foregroundStyle(isDestructive ? .red : Color("AppTextPrimary"))

            Spacer()

            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

struct AchievementCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                            ? LinearGradient(
                                colors: [Color("AppPrimary").opacity(0.4), Color("AppAccent").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color("AppSurface"), Color("AppBackground")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundStyle(isUnlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.35))

                if isUnlocked {
                    Circle()
                        .stroke(Color("AppAccent").opacity(0.6), lineWidth: 2)
                        .frame(width: 56, height: 56)
                }
            }

            Text(achievement.title)
                .font(.caption.bold())
                .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .glassCard(cornerRadius: 14, bordered: isUnlocked, elevation: .flat)
        .opacity(isUnlocked ? 1 : 0.72)
    }
}

struct HeroBannerCard: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Color("AppPrimary").opacity(0.2))
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(Color("AppAccent"))
            }
        }
        .padding(20)
        .heroCard(cornerRadius: 20)
    }
}

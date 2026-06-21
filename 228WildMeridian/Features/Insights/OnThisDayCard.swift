import SwiftUI

struct OnThisDayCard: View {
    @ObservedObject var appStorage: AppStorage

    private var items: [TimelineItem] {
        MusicAnalyticsService.onThisDayItems(appStorage: appStorage)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("On This Day")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Memories from this date in past years")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(Color("AppAccent"))
                    .frame(width: 44, height: 44)
                    .background(Color("AppAccent").opacity(0.12))
                    .clipShape(Circle())
            }

            if items.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "hourglass")
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text("Past entries from this date will appear here as your journal grows.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(items.prefix(3)) { item in
                        OnThisDayMemoryCell(item: item)
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
    }
}

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var appStorage: AppStorage
    @State private var showResetAlert = false

    private let achievementColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { appStorage.isAchievementUnlocked($0.id) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        statsCard
                        achievementsSection
                        settingsSection
                        footer
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 16)
                }
                .appScrollStyle()
            }
            .appTabRootLayout()
            .navigationTitle("Settings")
            .appNavigationStyle()
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    HapticManager.lightTap()
                }
                Button("Reset", role: .destructive) {
                    HapticManager.mediumTap()
                    appStorage.resetAllData()
                }
            } message: {
                Text("This will permanently delete all entries, favorites, and progress. This action cannot be undone.")
            }
        }
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Your Stats", subtitle: "Local progress overview")

            HStack(spacing: 10) {
                StatMetricCell(
                    value: "\(appStorage.emotionEntries.count + appStorage.reflections.count)",
                    label: "Entries",
                    icon: "doc.text.fill",
                    compact: true
                )
                StatMetricCell(
                    value: "\(appStorage.totalMinutesUsed)",
                    label: "Minutes",
                    icon: "timer",
                    compact: true
                )
                StatMetricCell(
                    value: "\(appStorage.streakDays)",
                    label: "Streak",
                    icon: "flame.fill",
                    compact: true
                )
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Achievements",
                subtitle: "\(unlockedCount) of \(AchievementDefinition.all.count) unlocked"
            )

            LazyVGrid(columns: achievementColumns, spacing: 12) {
                ForEach(AchievementDefinition.all) { achievement in
                    AchievementCell(
                        achievement: achievement,
                        isUnlocked: appStorage.isAchievementUnlocked(achievement.id)
                    )
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            Button {
                HapticManager.lightTap()
                rateApp()
            } label: {
                SettingsRowCell(title: "Rate Us", icon: "star.fill")
            }
            .buttonStyle(.plain)

            divider

            Button {
                HapticManager.lightTap()
                openPolicy(AppLegalLinks.privacyPolicy)
            } label: {
                SettingsRowCell(title: "Privacy", icon: "hand.raised.fill")
            }
            .buttonStyle(.plain)

            divider

            Button {
                HapticManager.lightTap()
                openPolicy(AppLegalLinks.termsOfUse)
            } label: {
                SettingsRowCell(title: "Terms", icon: "doc.text.fill")
            }
            .buttonStyle(.plain)

            divider

            Button {
                HapticManager.lightTap()
                showResetAlert = true
            } label: {
                SettingsRowCell(title: "Reset All Data", icon: "trash.fill", isDestructive: true)
            }
            .buttonStyle(.plain)
        }
        .glassCard(cornerRadius: 16, elevation: .floating)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color("AppTextSecondary").opacity(0.15))
            .frame(height: 1)
            .padding(.leading, 62)
    }

    private var footer: some View {
        Text("Version \(appVersion)")
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    private func openPolicy(_ link: AppLegalLinks) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

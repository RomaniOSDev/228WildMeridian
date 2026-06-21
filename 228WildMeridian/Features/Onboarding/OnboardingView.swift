import SwiftUI

private struct OnboardingPageData: Identifiable {
    let id: Int
    let headline: String
    let description: String
    let imageName: String
    let icon: String
    let badge: String
    let featureTags: [String]
}

struct OnboardingView: View {
    @EnvironmentObject private var appStorage: AppStorage
    @State private var currentPage = 0

    private let pages: [OnboardingPageData] = [
        OnboardingPageData(
            id: 0,
            headline: "Capture Inspirations",
            description: "Track your musical inspirations effortlessly.",
            imageName: "HomeHero",
            icon: "music.note.list",
            badge: "Step 1",
            featureTags: ["Song notes", "Quick log", "Timeline"]
        ),
        OnboardingPageData(
            id: 1,
            headline: "Document Emotions",
            description: "Write down emotions or stories related to each track.",
            imageName: "HomeWidgetMood",
            icon: "heart.text.square.fill",
            badge: "Step 2",
            featureTags: ["Mood map", "Emotion spectrum", "Insights"]
        ),
        OnboardingPageData(
            id: 2,
            headline: "Start Your Journey",
            description: "Add your first song entry now.",
            imageName: "HomeWidgetSession",
            icon: "headphones.circle.fill",
            badge: "Step 3",
            featureTags: ["Reflection sessions", "On This Day", "Export"]
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        onboardingPage(page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                bottomControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var topBar: some View {
        HStack {
            TagPill(
                text: pages[currentPage].badge,
                icon: "sparkles",
                tint: Color("AppAccent")
            )

            Spacer()

            Text("\(currentPage + 1) / \(pages.count)")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color("AppSurface").opacity(0.85))
                        .overlay {
                            Capsule()
                                .stroke(SurfacePalette.borderGradient, lineWidth: 0.5)
                        }
                )
        }
    }

    @ViewBuilder
    private func onboardingPage(_ page: OnboardingPageData) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                OnboardingVisualCard(
                    imageName: page.imageName,
                    icon: page.icon,
                    isActive: currentPage == page.id
                )

                VStack(spacing: 16) {
                    Text(page.headline)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)

                    Text(page.description)
                        .font(.body)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 8)

                    HStack(spacing: 8) {
                        ForEach(page.featureTags, id: \.self) { tag in
                            TagPill(text: tag, tint: Color("AppPrimary"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(22)
                .heroCard(cornerRadius: 22)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 18) {
            pageIndicator
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .glassCard(cornerRadius: 20, elevation: .floating)

            PrimaryButton(
                title: currentPage == pages.count - 1 ? "Get Started" : "Next",
                icon: currentPage == pages.count - 1 ? "checkmark.circle.fill" : "arrow.right"
            ) {
                advancePage()
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color("AppTextSecondary").opacity(0.35),
                                    Color("AppTextSecondary").opacity(0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func advancePage() {
        if currentPage < pages.count - 1 {
            HapticManager.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            HapticManager.mediumTap()
            HapticManager.successNotification()
            appStorage.completeOnboarding()
        }
    }
}

// MARK: - Visual Card

private struct OnboardingVisualCard: View {
    let imageName: String
    let icon: String
    let isActive: Bool

    @State private var appeared = false

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 240)
                .clipped()

            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.05),
                    Color("AppBackground").opacity(0.45),
                    Color("AppBackground").opacity(0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                Spacer()

                HStack {
                    DepthIconBadge(icon: icon, size: 56, tint: Color("AppPrimary"))
                    Spacer()
                }
                .padding(18)
            }
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(SurfacePalette.borderGradient, lineWidth: 1)
        }
        .depthShadow(.hero)
        .scaleEffect(appeared && isActive ? 1 : 0.94)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                appeared = true
            }
        }
        .onChange(of: isActive) { active in
            if active {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    appeared = true
                }
            }
        }
    }
}

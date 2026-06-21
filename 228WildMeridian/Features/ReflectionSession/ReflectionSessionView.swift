import Combine
import SwiftUI

struct ReflectionSessionView: View {
    @EnvironmentObject private var appStorage: AppStorage
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: ReflectionSessionViewModel

    init(appStorage: AppStorage) {
        _viewModel = StateObject(wrappedValue: ReflectionSessionViewModel(appStorage: appStorage))
    }

    var body: some View {
        ZStack {
            ZStack {
                ScrollView {
                VStack(spacing: 24) {
                    switch viewModel.state {
                    case .setup:
                        setupSection
                    case .running, .paused:
                        activeSessionSection
                    case .completed:
                        completedSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .padding(.bottom, 40)
            }
            .appScrollStyle()

            SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessOverlay)
            }
        }
        .appScreenBackground()
        .navigationTitle("Reflection Session")
        .appNavigationStyle(titleDisplayMode: .inline)
        .onChange(of: scenePhase) { phase in
            viewModel.handleScenePhase(phase)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if viewModel.state == .running {
                viewModel.tick()
            }
        }
    }

    private var setupSection: some View {
        VStack(spacing: 20) {
            HeroBannerCard(
                title: "Focused listening",
                subtitle: "Listen in your favorite music app, then reflect here with guided prompts.",
                icon: "headphones.circle.fill"
            )

            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(title: "Session Length", subtitle: "Choose your reflection window")

                Picker("Duration", selection: $viewModel.selectedMinutes) {
                    ForEach(viewModel.durationOptions, id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(16)
            .glassCard()

            PrimaryButton(title: "Start Session", icon: "play.fill") {
                viewModel.startSession()
            }
        }
    }

    private var activeSessionSection: some View {
        VStack(spacing: 24) {
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                ZStack {
                    Circle()
                        .stroke(Color("AppSurface"), lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            AngularGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary")],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progress)

                    VStack(spacing: 6) {
                        Text(timeString(viewModel.remainingSeconds))
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                        TagPill(
                            text: viewModel.state == .paused ? "Paused" : "Remaining",
                            tint: viewModel.state == .paused ? Color("AppTextSecondary") : Color("AppAccent")
                        )
                    }
                }
                .frame(width: 230, height: 230)
            }
            .padding(16)
            .glassCard()

            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView(title: "Guided Prompt", subtitle: "Let the music guide your writing")

                Text(viewModel.currentPrompt)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            .padding(16)
            .glassCard()

            HStack(spacing: 12) {
                if viewModel.state == .paused {
                    PrimaryButton(title: "Resume", icon: "play.fill") {
                        viewModel.resumeSession()
                    }
                } else {
                    Button {
                        HapticManager.lightTap()
                        viewModel.pauseSession()
                    } label: {
                        Label("Pause", systemImage: "pause.fill")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glassCard(cornerRadius: 14)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    HapticManager.lightTap()
                    viewModel.cancelSession()
                } label: {
                    Label("End", systemImage: "stop.fill")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .glassCard(cornerRadius: 14, bordered: false)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var completedSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color("AppAccent").opacity(0.15))
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color("AppAccent"))
            }

            Text("Session Complete")
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))

            Text("You reflected for \(viewModel.selectedMinutes) minutes. Capture your thoughts in Emotion Log or Song Reflections.")
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            PrimaryButton(title: "Done", icon: "checkmark") {
                HapticManager.lightTap()
                dismiss()
            }

            PrimaryButton(title: "Start Another Session", icon: "arrow.clockwise", style: .outline) {
                HapticManager.lightTap()
                viewModel.resetToSetup()
            }
        }
        .padding(.top, 30)
    }

    private func timeString(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

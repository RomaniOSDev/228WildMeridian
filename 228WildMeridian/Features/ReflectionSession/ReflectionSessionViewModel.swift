import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor
final class ReflectionSessionViewModel: ObservableObject {
    enum SessionState {
        case setup
        case running
        case paused
        case completed
    }

    @Published var selectedMinutes = 5
    @Published var state: SessionState = .setup
    @Published var remainingSeconds = 0
    @Published var currentPromptIndex = 0
    @Published var showSuccessOverlay = false

    let durationOptions = [5, 10, 15]
    let prompts = [
        "What emotion does this song bring up right now?",
        "Where were you when you first heard this track?",
        "Which lyric or melody stands out today?",
        "How does your body respond to this music?",
        "What memory surfaces while you listen?",
        "What would you tell your past self about this song?",
        "Does this track change your mood? How?",
        "What story does this song tell for you today?"
    ]

    private var sessionEndDate: Date?
    private var pausedRemainingSnapshot: Int?
    private let appStorage: AppStorage

    init(appStorage: AppStorage) {
        self.appStorage = appStorage
    }

    var progress: Double {
        let total = selectedMinutes * 60
        guard total > 0 else { return 0 }
        return 1 - (Double(remainingSeconds) / Double(total))
    }

    var currentPrompt: String {
        prompts[currentPromptIndex % prompts.count]
    }

    func startSession() {
        remainingSeconds = selectedMinutes * 60
        sessionEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        pausedRemainingSnapshot = nil
        currentPromptIndex = 0
        state = .running
        HapticManager.mediumTap()
    }

    func tick(now: Date = Date()) {
        guard state == .running, let endDate = sessionEndDate else { return }
        remainingSeconds = max(0, Int(endDate.timeIntervalSince(now).rounded(.up)))

        let elapsed = selectedMinutes * 60 - remainingSeconds
        let promptIndex = max(0, elapsed / 60) % prompts.count
        if promptIndex != currentPromptIndex {
            currentPromptIndex = promptIndex
        }

        if remainingSeconds == 0 {
            completeSession()
        }
    }

    func pauseSession() {
        guard state == .running else { return }
        pausedRemainingSnapshot = remainingSeconds
        state = .paused
    }

    func resumeSession() {
        guard state == .paused, let remaining = pausedRemainingSnapshot else { return }
        remainingSeconds = remaining
        sessionEndDate = Date().addingTimeInterval(TimeInterval(remaining))
        pausedRemainingSnapshot = nil
        state = .running
        HapticManager.lightTap()
    }

    func cancelSession() {
        state = .setup
        remainingSeconds = 0
        sessionEndDate = nil
        pausedRemainingSnapshot = nil
    }

    func completeSession() {
        state = .completed
        sessionEndDate = nil
        appStorage.completeReflectionSession(durationMinutes: selectedMinutes)
        HapticManager.successNotification()
        showSuccessOverlay = true
    }

    func resetToSetup() {
        state = .setup
        remainingSeconds = 0
        sessionEndDate = nil
        pausedRemainingSnapshot = nil
        showSuccessOverlay = false
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .inactive, .background:
            if state == .running {
                pauseSession()
            }
        case .active:
            break
        @unknown default:
            break
        }
    }
}

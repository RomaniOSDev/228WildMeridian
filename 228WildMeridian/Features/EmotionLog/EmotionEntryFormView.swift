import SwiftUI

struct EmotionEntryFormView: View {
    @ObservedObject var viewModel: EmotionLogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var songTitle = ""
    @State private var description = ""
    @State private var selectedEmotion = "😊"
    @State private var valence = 0.82
    @State private var energy = 0.55
    @State private var titleError = false
    @State private var descriptionError = false
    @State private var shakeTitle = false
    @State private var shakeDescription = false

    private let emotions = ["😊", "😢", "😌", "🔥", "💫", "😤", "🥰", "😔", "⚡️", "🌙"]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    songSection
                    descriptionSection
                    emojiSection
                    spectrumSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .padding(.bottom, 40)
            }
            .appScrollStyle()
        }
        .appScreenBackground()
        .navigationTitle("New Entry")
        .appNavigationStyle(titleDisplayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    HapticManager.lightTap()
                    dismiss()
                }
                .foregroundStyle(Color("AppTextSecondary"))
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveEntry()
                }
                .foregroundStyle(Color("AppPrimary"))
                .fontWeight(.bold)
            }
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "Save Entry", icon: "checkmark.circle.fill") {
                saveEntry()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [
                        Color("AppBackground").opacity(0),
                        Color("AppBackground").opacity(0.88),
                        Color("AppBackground")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    private var songSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Song", subtitle: "Which track moved you?")

            TextField("Song Title", text: $songTitle)
                .padding(14)
                .background(Color("AppBackground").opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(Color("AppTextPrimary"))
                .shake($shakeTitle)

            if titleError {
                Text("Please enter a song title.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Emotions", subtitle: "Describe what you felt")

            TextField("Your feelings or story", text: $description, axis: .vertical)
                .lineLimit(4...8)
                .padding(14)
                .background(Color("AppBackground").opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(Color("AppTextPrimary"))
                .shake($shakeDescription)

            if descriptionError {
                Text("Please describe your emotions.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var emojiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Emoji", subtitle: "Tap to set mood quickly")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(emotions, id: \.self) { emoji in
                    Button {
                        HapticManager.lightTap()
                        selectedEmotion = emoji
                        let preset = EmotionSpectrum.preset(for: emoji)
                        valence = preset.valence
                        energy = preset.energy
                    } label: {
                        Text(emoji)
                            .font(.system(size: 30))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(selectedEmotion == emoji ? Color("AppPrimary").opacity(0.35) : Color("AppBackground").opacity(0.5))
                                    .overlay {
                                        if selectedEmotion == emoji {
                                            Circle()
                                                .stroke(Color("AppPrimary"), lineWidth: 2)
                                        }
                                    }
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private var spectrumSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Emotion Spectrum", subtitle: "Fine-tune valence and energy")

            EmotionSpectrumPicker(
                valence: $valence,
                energy: $energy,
                selectedEmotion: $selectedEmotion
            )
        }
        .padding(16)
        .glassCard()
    }

    private func saveEntry() {
        titleError = false
        descriptionError = false

        let trimmedTitle = songTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        var hasError = false

        if trimmedTitle.isEmpty {
            titleError = true
            shakeTitle = true
            hasError = true
        }

        if trimmedDescription.isEmpty {
            descriptionError = true
            shakeDescription = true
            hasError = true
        }

        if hasError {
            HapticManager.warningNotification()
            return
        }

        HapticManager.mediumTap()
        if viewModel.saveEntry(
            songTitle: trimmedTitle,
            description: trimmedDescription,
            emotion: selectedEmotion,
            valence: valence,
            energy: energy
        ) {
            dismiss()
        }
    }
}

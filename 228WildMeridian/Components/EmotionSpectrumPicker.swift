import SwiftUI

struct EmotionSpectrumPicker: View {
    @Binding var valence: Double
    @Binding var energy: Double
    @Binding var selectedEmotion: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            spectrumSlider(
                title: "Valence",
                leftLabel: "Sad",
                rightLabel: "Happy",
                value: $valence
            )

            spectrumSlider(
                title: "Energy",
                leftLabel: "Calm",
                rightLabel: "Intense",
                value: $energy
            )

            EmotionSpectrumMapView(valence: valence, energy: energy)
                .frame(height: 120)

            Text("Mapped emoji: \(selectedEmotion)")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .onChange(of: valence) { _ in syncEmoji() }
        .onChange(of: energy) { _ in syncEmoji() }
    }

    func applyEmojiPreset(_ emoji: String) {
        let preset = EmotionSpectrum.preset(for: emoji)
        valence = preset.valence
        energy = preset.energy
        selectedEmotion = emoji
    }

    private func syncEmoji() {
        selectedEmotion = EmotionSpectrum.closestEmoji(valence: valence, energy: energy)
    }

    private func spectrumSlider(
        title: String,
        leftLabel: String,
        rightLabel: String,
        value: Binding<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))

            HStack {
                Text(leftLabel)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                Slider(value: value, in: 0...1)
                    .tint(Color("AppAccent"))
                Text(rightLabel)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }
}

struct EmotionSpectrumMapView: View {
    let valence: Double
    let energy: Double
    var points: [SpectrumPoint] = []
    var highlightValence: Double?
    var highlightEnergy: Double?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("AppSurface"))

                Canvas { context, size in
                    let inset: CGFloat = 12
                    let plotWidth = size.width - inset * 2
                    let plotHeight = size.height - inset * 2

                    for point in points {
                        let x = inset + plotWidth * point.valence
                        let y = inset + plotHeight * (1 - point.energy)
                        let rect = CGRect(x: x - 3, y: y - 3, width: 6, height: 6)
                        context.fill(Path(ellipseIn: rect), with: .color(Color("AppTextSecondary").opacity(0.45)))
                    }

                    let activeValence = highlightValence ?? valence
                    let activeEnergy = highlightEnergy ?? energy
                    let x = inset + plotWidth * activeValence
                    let y = inset + plotHeight * (1 - activeEnergy)
                    let activeRect = CGRect(x: x - 8, y: y - 8, width: 16, height: 16)
                    context.fill(Path(ellipseIn: activeRect), with: .color(Color("AppPrimary")))
                    context.stroke(Path(ellipseIn: activeRect), with: .color(Color("AppTextPrimary")), lineWidth: 2)
                }

                VStack {
                    HStack {
                        Text("Calm")
                        Spacer()
                        Text("Intense")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    Spacer()
                    HStack {
                        Text("Sad")
                        Spacer()
                        Text("Happy")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                }
            }
        }
    }
}

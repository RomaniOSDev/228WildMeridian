import SwiftUI

struct ReflectionFormView: View {
    @ObservedObject var viewModel: SongReflectionsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var songTitle = ""
    @State private var reflectionText = ""
    @State private var reflectionDate = Date()
    @State private var titleError = false
    @State private var textError = false
    @State private var shakeTitle = false
    @State private var shakeText = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeaderView(title: "Song Title", subtitle: "What track are you reflecting on?")

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

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeaderView(title: "Your Reflection", subtitle: "Write freely about how this song feels")

                    TextField("Your Reflection", text: $reflectionText, axis: .vertical)
                        .lineLimit(4...10)
                        .padding(14)
                        .background(Color("AppBackground").opacity(0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .shake($shakeText)

                    if textError {
                        Text("Please write your reflection.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(16)
                .glassCard()

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeaderView(title: "Date", subtitle: "When did this reflection happen?")

                    DatePicker("Date", selection: $reflectionDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(Color("AppPrimary"))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .padding(16)
                .glassCard()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 100)
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
            PrimaryButton(title: "Save Reflection", icon: "square.and.pencil") {
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

    private func saveEntry() {
        titleError = false
        textError = false

        let trimmedTitle = songTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedText = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)

        var hasError = false

        if trimmedTitle.isEmpty {
            titleError = true
            shakeTitle = true
            hasError = true
        }

        if trimmedText.isEmpty {
            textError = true
            shakeText = true
            hasError = true
        }

        if hasError {
            HapticManager.warningNotification()
            return
        }

        HapticManager.mediumTap()
        if viewModel.saveEntry(songTitle: trimmedTitle, text: trimmedText, date: reflectionDate) {
            dismiss()
        }
    }
}

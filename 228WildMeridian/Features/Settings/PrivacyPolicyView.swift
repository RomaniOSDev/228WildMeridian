import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var policyText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    if policyText.isEmpty {
                        ProgressView()
                            .tint(Color("AppPrimary"))
                            .padding(.top, 40)
                    } else if let attributed = try? AttributedString(
                        markdown: policyText,
                        options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
                    ) {
                        Text(attributed)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .tint(Color("AppPrimary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                    } else {
                        Text(policyText)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                    }
                }
                .appScrollStyle()
            }
            .appScreenBackground()
            .navigationTitle("Privacy Policy")
            .appNavigationStyle(titleDisplayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        HapticManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .onAppear {
                loadPolicy()
            }
        }
    }

    private func loadPolicy() {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            policyText = "Privacy policy could not be loaded."
            return
        }
        policyText = text
    }
}

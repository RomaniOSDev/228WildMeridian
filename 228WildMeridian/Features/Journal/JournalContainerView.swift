import SwiftUI

enum JournalSection: String, CaseIterable {
    case reflections = "Reflections"
    case vault = "Vault"
}

struct JournalContainerView: View {
    @State private var section: JournalSection = .reflections

    var body: some View {
        VStack(spacing: 0) {
            CustomSegmentedControl(selection: $section)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            switch section {
            case .reflections:
                SongReflectionsView()
            case .vault:
                InspirationalVaultView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appTabRootLayout()
    }
}

import Foundation
import UIKit

enum AppLegalLinks: String {
    case privacyPolicy = "https://wild228meridian.site/privacy/275"
    case termsOfUse = "https://wild228meridian.site/terms/275"

    var url: URL? {
        URL(string: rawValue)
    }

    static func open(_ link: AppLegalLinks) {
        guard let url = link.url else { return }
        UIApplication.shared.open(url)
    }
}

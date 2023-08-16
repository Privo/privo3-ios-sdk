import Foundation

struct AgeVerificationStoreData: Codable {
    var displayMode = "redirect"
    let serviceIdentifier: String
    let redirectUrl: String?
    let profile: AgeVerificationProfile?
}


import Foundation

struct AgeVerificationStoreData : Encodable, Decodable {
    var displayMode = "redirect"
    let serviceIdentifier: String;
    let redirectUrl: String?;

    let profile: AgeVerificationProfile?;
}


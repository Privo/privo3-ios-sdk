import Foundation

struct VerificationData: Encodable {
    let profile: UserVerificationProfile
    let config: VerificationConfig
    var sourceOrigin: String?
    var redirectUrl: String?
}

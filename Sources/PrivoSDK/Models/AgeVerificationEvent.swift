import Foundation

public struct AgeVerificationEvent: Codable {
    public let status: AgeVerificationStatus
    public let profile: AgeVerificationProfile?
}


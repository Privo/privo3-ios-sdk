import Foundation

public struct AgeVerificationEvent : Encodable, Decodable {
    
    public let status: AgeVerificationStatus
    
    /// child profile verified by PRIVO
    public let profile: AgeVerificationProfile?
}

struct AgeVerificationEventInternal: Encodable, Decodable {
    let status: AgeVerificationStatusInternal
    let profile: AgeVerificationProfile?
    let ageVerificationId: String?
}

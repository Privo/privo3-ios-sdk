import Foundation

struct AgeVerificationEventInternal: Codable {
   let status: AgeVerificationStatusInternal
   let profile: AgeVerificationProfile?
   let ageVerificationId: String?
}

extension AgeVerificationEventInternal {
    
    private var toStatus: AgeVerificationStatus? {
        guard status == .Closed else { return AgeVerificationStatus.init(rawValue: status.rawValue) }
        return nil
    }
    
    var toEvent: AgeVerificationEvent? {
        guard let status = toStatus else { return nil }
        return .init(status: status, profile: profile)
    }
}

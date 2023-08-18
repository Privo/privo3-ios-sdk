import Foundation

struct AgeVerificationEventTO: Codable {
   let status: AgeVerificationStatusTO
   let profile: AgeVerificationProfile?
   let ageVerificationId: String?
}

extension AgeVerificationEventTO {
    
    private var toStatus: AgeVerificationStatus? {
        guard status == .Closed else { return .init(rawValue: status.rawValue) }
        return nil
    }
    
    var toEvent: AgeVerificationEvent? {
        guard let status = toStatus else { return nil }
        return .init(status: status, profile: profile)
    }
}

import Foundation

struct AgeGateEventInternal: Codable, Hashable {
    let status: AgeGateStatusInternal
    let userIdentifier: String?
    let nickname: String?
    let agId: String?
    let ageRange: AgeRange?
    let countryCode: String?
}


extension AgeGateEventInternal {
    
    private var toStatus: AgeGateStatus? {
        guard status == .Closed else {  return .init(rawValue: status.rawValue) }
        return nil
    }
    
    func toEvent(nickname: String?) -> AgeGateEvent? {
        guard let status = toStatus else { return nil }
        return .init(status: status,
                     userIdentifier: userIdentifier,
                     nickname: nickname,
                     agId: agId,
                     ageRange: ageRange,
                     countryCode: countryCode)
    }
    
}

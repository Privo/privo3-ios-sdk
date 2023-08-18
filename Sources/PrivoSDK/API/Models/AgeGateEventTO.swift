import Foundation

struct AgeGateEventTO: Codable, Hashable {
    let status: AgeGateStatusTO
    let userIdentifier: String?
    let agId: String?
    let ageRange: AgeRangeTO?
    let countryCode: String?
}

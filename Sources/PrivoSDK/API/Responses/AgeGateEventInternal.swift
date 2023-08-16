import Foundation

struct AgeGateEventInternal: Codable, Hashable {
    let status: AgeGateStatusInternal
    let userIdentifier: String?
    let agId: String?
    let ageRange: AgeRange?
    let countryCode: String?
}

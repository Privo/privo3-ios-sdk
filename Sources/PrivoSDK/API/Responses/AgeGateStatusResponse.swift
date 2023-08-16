import Foundation

struct AgeGateStatusResponse: Codable, Hashable {
    let status: AgeGateStatusTO
    let agId: String?
    let ageRange: AgeRange?
    let extUserId: String?
    let countryCode: String?
}

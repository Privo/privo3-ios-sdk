import Foundation

struct AgeGateActionResponse: Codable, Hashable {
    let action: AgeGateActionTO
    let agId: String
    let ageRange: AgeRangeTO?
    let extUserId: String?
    let countryCode: String?
}

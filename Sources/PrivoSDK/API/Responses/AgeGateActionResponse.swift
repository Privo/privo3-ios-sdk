import Foundation

struct AgeGateActionResponse: Codable, Hashable {
    let action: AgeGateAction
    let agId: String
    let ageRange: AgeRange?
    let extUserId: String?
    let countryCode: String?
}

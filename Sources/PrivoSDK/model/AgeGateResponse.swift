import Foundation

internal struct AgeGateActionResponse: Decodable, Encodable, Hashable {
    let action: AgeGateAction;
    let agId: String;
    let ageRange: AgeRange?
    let extUserId: String?
    let countryCode: String?
}
internal struct AgeGateStatusResponse: Decodable, Encodable, Hashable {
    let status: AgeGateStatusTO;
    let agId: String?;
    let ageRange: AgeRange?
    let extUserId: String?
    let countryCode: String?
}

import Foundation

struct AgeServiceSettingsResponse: Codable {
    let isGeoApiOn: Bool
    let isAllowSelectCountry: Bool
    let isProvideUserId: Bool
    let isShowStatusUi: Bool
    let poolAgeGateStatusInterval: Int
    let verificationApiKey: String?
    let p2SiteId: Int?
    let logoUrl: String?
    let customerSupportEmail: String?
    let isMultiUserOn: Bool
}

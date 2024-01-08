import Foundation

internal struct AgeGateEventInternal: Decodable, Encodable, Hashable {
    let status: AgeGateStatusInternal
    let userIdentifier: String?
    let agId: String?
    let ageRange: AgeRange?
    let countryCode: String?
}

@available(*, deprecated, message: "We don't store previous events anymore, so we don't need expiration")
internal struct AgeGateExpireEvent: Decodable, Encodable, Hashable {
    let event: AgeGateEvent
    let expires: TimeInterval
}

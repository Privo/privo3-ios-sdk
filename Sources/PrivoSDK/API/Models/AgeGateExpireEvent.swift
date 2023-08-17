import Foundation

@available(*, deprecated, message: "We don't store previous events anymore, so we don't need expiration")
internal struct AgeGateExpireEvent: Codable, Hashable {
    let event: AgeGateEvent
    let expires: TimeInterval
}

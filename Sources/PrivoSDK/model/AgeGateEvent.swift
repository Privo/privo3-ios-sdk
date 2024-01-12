import Foundation

public struct AgeGateEvent: Decodable, Encodable, Hashable {
    
    public let status: AgeGateStatus
    
    /// External user identifier.
    public let userIdentifier: String?
    
    public let nickname: String?
    
    /// Age gate identifier.
    public let agId: String?
    
    public let ageRange: AgeRange?
    
    /// Two-letter country code [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).
    public let countryCode: String?
}

import Foundation

public struct AgeGateEvent: Hashable {
    public let status: AgeGateStatus
    public let userIdentifier: String?
    public let nickname: String?
    public let agId: String?
    public let ageRange: AgeRange?
    public let countryCode: String?
    
}

//MARK: - Codable's implementation

extension AgeGateEvent: Codable {
    
    enum CodingKeys: String, CodingKey {
        case status
        case userIdentifier
        case nickname
        case agId
        case ageRange
        case countryCode
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(AgeGateStatus.self, forKey: .status)
        userIdentifier = try container.decodeIfPresent(String.self, forKey: .userIdentifier)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        agId = try container.decodeIfPresent(String.self, forKey: .agId)
        ageRange = try container.decodeIfPresent(AgeRange.self, forKey: .ageRange)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
    }
    
}

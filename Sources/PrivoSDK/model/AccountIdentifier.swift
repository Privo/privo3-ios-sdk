import Foundation

public enum AccountIdentifier: Encodable {
    case userName(String)
    case displayName(String)
    case email(String)
    case phone(String)
    case externalUserIdentifier(String)
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case displayName = "display_name"
        case email
        case phone
        case externalUserIdentifier = "external_user_identifier"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .userName(let value):
            try container.encode(value, forKey: .userName)
        case .displayName(let value):
            try container.encode(value, forKey: .displayName)
        case .email(let value):
            try container.encode(value, forKey: .email)
        case .phone(let value):
            try container.encode(value, forKey: .phone)
        case .externalUserIdentifier(let value):
            try container.encode(value, forKey: .externalUserIdentifier)
        }
    }
}

struct AccountInfoResponse: Decodable {
    let sid: String
}

import Foundation

public struct UserInfo {
    public let firstName: String?
    public let lastName: String?
    public let gender: String?
    public let email: String?
    public let birthdate: Date?
    public let displayName: String?
    public let roleIdentifier: String
    public let permissions: [Permission]
    
    public struct Permission {
        
        public enum Category: String {
            case standard
            case optional
        }
        
        public let consentDate: Date
        public let on: Bool
        public let featureIdentifier: String
        public let category: Category
        public let active: Bool
    }
}

struct UserInfoResponse: Decodable {
    let givenName: String?
    let lastName: String?
    let gender: String?
    let email: String?
    let birthdate: String?
    let roleIdentifier: String
    let permissions: [Permission]
    let displayName: String?
    struct Permission: Decodable {
        
        enum Category: String, Decodable {
            case standard
            case optional
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let stringValue = try container.decode(String.self)

                switch stringValue.lowercased() {
                case Self.standard.rawValue.lowercased():
                    self = .standard
                case Self.optional.rawValue.lowercased():
                    self = .optional
                default:
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Cannot initialize Category from invalid String value \(stringValue)"
                        )
                    )
                }
            }
            
            var toPublic: UserInfo.Permission.Category {
                switch self {
                case .standard:
                    return UserInfo.Permission.Category.standard
                case .optional:
                    return UserInfo.Permission.Category.optional
                }
            }
        }
        
        let consentDate: Int
        let on: Bool
        let featureIdentifier: String
        let category: Category
        let active: Bool
        
        var permission: UserInfo.Permission {
            .init(consentDate: Date(timeIntervalSince1970:  TimeInterval(consentDate)),
                  on: on,
                  featureIdentifier: featureIdentifier,
                  category: category.toPublic,
                  active: active
            )
        }
    }
    
    var userinfo: UserInfo {
        return .init(
            firstName: givenName,
            lastName: lastName,
            gender: gender,
            email: email,
            birthdate: {
                if let birthdate = birthdate {
                    return DateFormatter(format: "yyyy-MM-dd").date(from: birthdate)
                } else {
                    return nil
                }
            }(),
            displayName: displayName,
            roleIdentifier: roleIdentifier,
            permissions: permissions.map(\.permission)
        )
    }
}

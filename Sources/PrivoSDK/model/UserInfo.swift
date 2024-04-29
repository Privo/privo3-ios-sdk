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
    public let consentRequests: [ConsentRequest]
    
    public struct ConsentRequest {
        
        public enum Status: String {
            case approved
            case denied
            case expired
            case pending
            case postponed
        }
        
        public let status: Status
        public let consentDate: Date
    }
    
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
    let consentRequests: [ConsentRequest]
    let displayName: String?
    
    struct ConsentRequest: Decodable {
        
        enum Status: String, Decodable {
            case approved
            case denied
            case expired
            case pending
            case postponed
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let stringValue = try container.decode(String.self)

                switch stringValue.lowercased() {
                case Self.approved.rawValue.lowercased():
                    self = .approved
                case Self.denied.rawValue.lowercased():
                    self = .denied
                case Self.expired.rawValue.lowercased():
                    self = .expired
                case Self.pending.rawValue.lowercased():
                    self = .pending
                case Self.postponed.rawValue.lowercased():
                    self = .postponed
                default:
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Cannot initialize Status from invalid String value \(stringValue)"
                        )
                    )
                }
            }
            
            var `public`: UserInfo.ConsentRequest.Status {
                switch self {
                case .approved:
                    return .approved
                case .denied:
                    return .denied
                case .expired:
                    return .expired
                case .pending:
                    return .pending
                case .postponed:
                    return .postponed
                }
            }
        }
        
        let status: Status
        let consentDate: Int
        
        var `public`: UserInfo.ConsentRequest {
            .init(status: status.public, consentDate: Date(timeIntervalSince1970:  TimeInterval(consentDate)))
        }
    }
    
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
            
            var `public`: UserInfo.Permission.Category {
                switch self {
                case .standard:
                    return .standard
                case .optional:
                    return .optional
                }
            }
        }
        
        let consentDate: Int
        let on: Bool
        let featureIdentifier: String
        let category: Category
        let active: Bool
        
        var `public`: UserInfo.Permission {
            .init(consentDate: Date(timeIntervalSince1970:  TimeInterval(consentDate)),
                  on: on,
                  featureIdentifier: featureIdentifier,
                  category: category.public,
                  active: active
            )
        }
    }
    
    var `public`: UserInfo {
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
            permissions: permissions.map(\.public),
            consentRequests: consentRequests.map(\.public)
        )
    }
}

import Foundation

public struct UserInfo {
    public let givenName: String?
    public let lastName: String?
    public let gender: String?
    public let email: String?
    public let birthdate: String?
    public let displayName: String?
    public let roleIdentifier: String
    public let permissions: [Permission]
    
    public struct Permission {
        public let consentDate: Date
        public let on: Bool
        public let featureIdentifier: String
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
        let consentDate: Int
        let on: Bool
        let featureIdentifier: String
        
        var permission: UserInfo.Permission {
            .init(consentDate: Date(timeIntervalSince1970:  TimeInterval(consentDate)),
                  on: on,
                  featureIdentifier: featureIdentifier
            )
        }
    }
    
    var userinfo: UserInfo {
        return .init(
            givenName: givenName,
            lastName: lastName,
            gender: gender,
            email: email,
            birthdate: birthdate,
            displayName: displayName,
            roleIdentifier: roleIdentifier,
            permissions: permissions.map(\.permission),
        )
    }
}

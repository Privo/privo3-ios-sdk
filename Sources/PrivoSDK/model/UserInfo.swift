import Foundation

public struct UserInfo {
    public let givenName: String?
    public let lastName: String?
    public let gender: String?
    public let email: String?
    public let birthdate: String?
    public let displayName: String?
}

struct UserInfoResponse: Decodable {
    let givenName: String?
    let lastName: String?
    let gender: String?
    let email: String?
    let birthdate: String?
    let permissions: [Permission]
    let displayName: String?
    struct Permission: Decodable {
        let featureIdentifier: String
    }
    
    var userinfo: UserInfo {
        return .init(
            givenName: givenName,
            lastName: lastName,
            gender: gender,
            email: email,
            birthdate: birthdate,
            displayName: displayName
        )
    }
}

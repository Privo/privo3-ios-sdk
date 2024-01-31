import Foundation

struct OAuthToken: Encodable {
    var grant_type: String = "client_credentials"
    var scope: String = "openid profile user_profile update_password_link TRUST"
    let client_id: String
    let client_secret: String
}

struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let scope: String
}

import Foundation

struct OAuthToken: Encodable {
    var grant_type: String = "client_credentials"
    var scope: String = "openid profile email user_profile update_password_link service_profile TRUST additional_info address connected_profiles consent_url delete_account manage_consent offline_access phone"
    let client_id: String
    let client_secret: String
}

struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let scope: String
}

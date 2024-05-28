import Foundation

struct OAuthClientCredentials: Encodable {
    let grant_type: String = "client_credentials"
    let scope: String = "openid profile email user_profile update_password_link service_profile TRUST additional_info address connected_profiles consent_url delete_account manage_consent offline_access phone"
    let client_id: String
    let client_secret: String
}

struct OAuthAuthorizationCode: Encodable {
    let grant_type: String = "authorization_code"
    let scope: String = "openid profile email user_profile update_password_link service_profile TRUST additional_info address connected_profiles consent_url delete_account manage_consent offline_access phone"
    let code: String
    let client_id: String
    let client_secret: String
    let redirect_uri: String = "https://my\(PrivoInternal.configuration.urlPrefix).privo.com/openid_connect_login"
}

struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let scope: String
}

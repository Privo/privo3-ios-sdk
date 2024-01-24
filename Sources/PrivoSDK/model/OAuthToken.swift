import Foundation

struct OAuthToken: Codable {
    var grant_type: String = "client_credentials"
    var scope: String = "openid profile user_profile TRUST"
    let client_id: String
    let client_secret: String
}

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

extension OAuthToken {
    func toQueryItems() -> [URLQueryItem] {
        let mirror = Mirror(reflecting: self)
        var items: [URLQueryItem] = []
        
        for (key, value) in mirror.children {
            if let key = key,
               let stringValue = value as? String,
               let codingKey = CodingKeys(stringValue: key)
            {
                let queryItem = URLQueryItem(name: codingKey.stringValue, value: stringValue)
                items.append(queryItem)
            }
        }

        return items
    }
}

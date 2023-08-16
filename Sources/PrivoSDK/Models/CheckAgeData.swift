import Foundation

public struct CheckAgeData: Hashable {
    
    public let userIdentifier: String? // uniq user identifier
    public let birthDateYYYYMMDD: String? // "yyyy-MM-dd" format
    public let birthDateYYYYMM: String? // "2021-03" format
    public let birthDateYYYY: String? // "2021" format
    public let age: Int? // 31, age format
    public let countryCode: String? // Alpha-2 country code, e.g US
    public let nickname: String? // Nickname of user for multi-user integration. Can not be an empty string ("").
    
    public init(userIdentifier: String? = nil,
                birthDateYYYYMMDD: String? = nil,
                birthDateYYYYMM: String? = nil,
                birthDateYYYY: String? = nil,
                age: Int? = nil,
                countryCode: String? = nil,
                nickname: String? = nil) {
        self.userIdentifier = userIdentifier
        self.birthDateYYYYMMDD = birthDateYYYYMMDD
        self.birthDateYYYYMM = birthDateYYYYMM
        self.birthDateYYYY = birthDateYYYY
        self.age = age
        self.countryCode = countryCode
        self.nickname = nickname
    }
    
}


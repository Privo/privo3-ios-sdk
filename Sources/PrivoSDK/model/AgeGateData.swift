import Foundation

internal struct CheckAgeStoreData: Encodable {
    private let displayMode = "redirect";
    private let isNativeIntegration = true;
    
    let serviceIdentifier: String;
    let settings: AgeServiceSettings;
    let userIdentifier: String?;
    let nickname: String?;
    let countryCode: String?;
    let birthDateYYYYMMDD: String?
    let birthDateYYYYMM: String?
    let birthDateYYYY: String?
    let redirectUrl: String?;
    let agId: String?;
    let fpId: String?;
    let age: Int?
    
    init(serviceIdentifier: String,
         settings: AgeServiceSettings,
         userIdentifier: String?,
         nickname: String?,
         countryCode: String?,
         birthDateYYYYMMDD: String?,
         birthDateYYYYMM: String?,
         birthDateYYYY: String?,
         redirectUrl: String?,
         agId: String?,
         fpId: String?,
         age: Int?) {
        self.serviceIdentifier = serviceIdentifier
        self.settings = settings
        self.userIdentifier = userIdentifier
        self.nickname = nickname
        self.countryCode = countryCode
        self.birthDateYYYYMMDD = birthDateYYYYMMDD
        self.birthDateYYYYMM = birthDateYYYYMM
        self.birthDateYYYY = birthDateYYYY
        self.redirectUrl = redirectUrl
        self.agId = agId
        self.fpId = fpId
        self.age = age
    }
    
    init(serviceIdentifier: String,
                     state: AgeState,
                     data: CheckAgeData,
                     redirectUrl: String?) {
        self.init(serviceIdentifier: serviceIdentifier,
             settings: state.settings,
             userIdentifier: data.userIdentifier,
             nickname: data.nickname,
             countryCode: data.countryCode,
             birthDateYYYYMMDD: data.birthDateYYYYMMDD,
             birthDateYYYYMM: data.birthDateYYYYMM,
             birthDateYYYY: data.birthDateYYYY,
             redirectUrl: redirectUrl,
             agId: state.agId,
             fpId: state.fpId,
             age: data.age)
    }
    
}

public struct CheckAgeData: Hashable {
    
    /// Unique external user identifier.
    /// Please don't use empty string ("") as a value. It will cause an error. We support real values or nil if you don't have it.
    public let userIdentifier: String?
    
    /// External user birthdate in "yyyy-MM-dd" format.
    public let birthDateYYYYMMDD: String?
    
    /// External user birth date in "yyyy-MM" format.
    public let birthDateYYYYMM: String?
    
    /// External user birth date in "yyyy" format. Derived birthDate will be calculated with Dec 31 by default.
    public let birthDateYYYY: String?
    
    /// External user age format. Derived birthDate will be calculated with current day and month by default.
    public let age: Int?
    
    /// Two-letter country code [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2), e.g. US
    public let countryCode: String?
    
    ///  Nickname.
    ///  Please use only in case of multi-user integration.
    ///  Please don't use empty string "" in it.
    public let nickname: String?
    
    public init(
        userIdentifier: String? = nil,
        birthDateYYYYMMDD: String? = nil,
        birthDateYYYYMM: String? = nil,
        birthDateYYYY: String? = nil,
        age: Int? = nil,
        countryCode: String? = nil,
        nickname: String? = nil
    ) {
        self.userIdentifier = userIdentifier
        self.birthDateYYYYMMDD = birthDateYYYYMMDD
        self.birthDateYYYYMM = birthDateYYYYMM
        self.birthDateYYYY = birthDateYYYY
        self.age = age
        self.countryCode = countryCode
        self.nickname = nickname
    }
}


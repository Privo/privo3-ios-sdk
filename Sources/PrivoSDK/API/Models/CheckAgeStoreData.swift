import Foundation

struct CheckAgeStoreData: Encodable {
    
    //MARK: - Internal properties
    
    let serviceIdentifier: String
    let settings: AgeServiceSettingsResponse
    let userIdentifier: String?
    let nickname: String?
    let countryCode: String?
    let birthDateYYYYMMDD: String?
    let birthDateYYYYMM: String?
    let birthDateYYYY: String?
    let redirectUrl: String?
    let agId: String?
    let fpId: String?
    let age: Int?
    
    //MARK: - Private properties
    
    private let displayMode = "redirect"
    private let isNativeIntegration = true
    
    //MARK: - Internal initialisers
    
    init(serviceIdentifier: String,
         settings: AgeServiceSettingsResponse,
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

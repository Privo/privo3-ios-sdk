import Foundation

public struct AgeVerificationProfile: Encodable, Decodable {
    
    /// External user identifier
    public let userIdentifier: String?
    
    /// Child user first name
    public let firstName: String?
    
    /// Child user email address
    public let email: String?
    
    /// External user birth date in "yyyy-MM-dd" format
    public let birthDateYYYYMMDD: String?
    
    /// Child user phone number in the full international format (E.164, e.g. "+17024181234")
    public let phoneNumber: String?
    
    public init(
        userIdentifier: String? = nil,
        firstName: String? = nil,
        email: String? = nil,
        birthDateYYYYMMDD: String? = nil,
        phoneNumber: String? = nil
    ) {
        self.userIdentifier = userIdentifier
        self.firstName = firstName
        self.email = email
        self.birthDateYYYYMMDD = birthDateYYYYMMDD
        self.phoneNumber = phoneNumber

    }
}

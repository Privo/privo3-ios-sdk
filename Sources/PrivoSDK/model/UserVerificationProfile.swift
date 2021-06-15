//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 14.06.2021.
//

public struct UserVerificationProfile: Encodable {
    public let firstName: String?
    public let lastName: String?
    public let birthDate: String?
    public let email: String?
    public let postalCode: String?
    public let phone: String?
    public let partnerDefinedUniqueID: String?
    public init(firstName: String? = nil, lastName: String? = nil, birthDate: String? = nil, email: String? = nil, postalCode: String? = nil, phone: String? = nil, partnerDefinedUniqueID: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.email = email
        self.postalCode = postalCode
        self.phone = phone
        self.partnerDefinedUniqueID = partnerDefinedUniqueID
    }
}

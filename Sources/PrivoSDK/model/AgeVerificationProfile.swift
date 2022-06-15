//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 13.06.2022.
//

import Foundation


public struct AgeVerificationProfile : Encodable, Decodable {
    public let userIdentifier: String?;
    public let ageGateIdentifier: String?; // for internal usage.
    public let firstName: String?;
    public let email: String?;
    public let birthDateYYYYMMDD: String?; // "yyyy-MM-dd" format
    public let phoneNumber: String?; // in the full international format (E.164, e.g. “+17024181234”)
    
    public init(
        userIdentifier: String? = nil,
        firstName: String? = nil,
        email: String? = nil,
        birthDateYYYYMMDD: String? = nil,
        phoneNumber: String? = nil,
        ageGateIdentifier: String? = nil
    ) {
        self.userIdentifier = userIdentifier
        self.firstName = firstName
        self.email = email
        self.birthDateYYYYMMDD = birthDateYYYYMMDD
        self.phoneNumber = phoneNumber
        self.ageGateIdentifier = ageGateIdentifier

    }
}

//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public struct UserVerificationProfile: Encodable {
    
    public var firstName: String?
    
    public var lastName: String?
    
    /// Date string in the "yyyy-MM-dd" date-format
    public var birthDateYYYYMMDD: String?
    
    public var email: String?
    
    public var postalCode: String?
    
    /// Phone number in the full international format (E.164, e.g. "+17024181234")
    public var phone: String?
    
    /// Unique identifier passed by Partner and returned in all responses by PRIVO.
    public var partnerDefinedUniqueID: String?
    
    @available(*, deprecated)
    public var birthDate: Date?
    
    @available(*, deprecated)
    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        birthDate: Date? = nil,
        email: String? = nil,
        postalCode: String? = nil,
        phone: String? = nil,
        partnerDefinedUniqueID: String? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.email = email
        self.postalCode = postalCode
        self.phone = phone
        self.partnerDefinedUniqueID = partnerDefinedUniqueID
    }
    
    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        birthDateYYYYMMDD: String? = nil,
        email: String? = nil,
        postalCode: String? = nil,
        phone: String? = nil,
        partnerDefinedUniqueID: String? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDateYYYYMMDD = birthDateYYYYMMDD
        self.email = email
        self.postalCode = postalCode
        self.phone = phone
        self.partnerDefinedUniqueID = partnerDefinedUniqueID
    }
    
    public init(partnerDefinedUniqueID: String? = nil) {
        self.partnerDefinedUniqueID = partnerDefinedUniqueID
    }
    
    enum CodingKeys: CodingKey {
      case firstName, lastName, birthDate, birthDateYYYYMMDD, email, postalCode, phone, partnerDefinedUniqueID
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(birthDate?.toMilliseconds(), forKey: .birthDate)
        try container.encode(birthDateYYYYMMDD, forKey: .birthDateYYYYMMDD)
        try container.encode(email, forKey: .email)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(phone, forKey: .phone)
        try container.encode(partnerDefinedUniqueID, forKey: .partnerDefinedUniqueID)
    }
}

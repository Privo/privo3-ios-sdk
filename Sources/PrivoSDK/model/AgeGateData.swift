//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.04.2022.
//

import Foundation

internal struct CheckAgeStoreData: Encodable {
    private let displayMode = "redirect";
    
    let serviceIdentifier: String;
    let settings: AgeServiceSettings;
    let userIdentifier: String?;
    let countryCode: String?;
    let birthDateYYYYMMDD: String?
    let redirectUrl: String?;
    let agId: String?;
    let fpId: String?;
}

public struct CheckAgeData: Hashable {
    public let userIdentifier: String? ; // uniq user identifier
    public let birthDateYYYYMMDD: String?; // "yyyy-MM-dd" format
    public let countryCode: String?; // Alpha-2 country code, e.g US
    
    public init(
        userIdentifier: String? = nil,
        birthDateYYYYMMDD: String? = nil,
        countryCode: String? = nil
    ) {
        self.userIdentifier = userIdentifier
        self.birthDateYYYYMMDD = birthDateYYYYMMDD
        self.countryCode = countryCode
    }
}

public struct RecheckAgeData: Hashable {
    public let userIdentifier: String? ; // uniq user identifier
    public let countryCode: String?; // Alpha-2 country code, e.g US
    
    public init(
        userIdentifier: String? = nil,
        countryCode: String? = nil
    ) {
        self.userIdentifier = userIdentifier
        self.countryCode = countryCode
    }
}

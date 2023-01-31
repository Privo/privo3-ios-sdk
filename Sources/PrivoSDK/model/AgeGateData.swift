//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.04.2022.
//

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
}

public struct CheckAgeData: Hashable {
    public let userIdentifier: String? ; // uniq user identifier
    public let birthDateYYYYMMDD: String?; // "yyyy-MM-dd" format
    public let birthDateYYYYMM: String? // "2021-03" format
    public let birthDateYYYY: String? // "2021" format
    public let countryCode: String?; // Alpha-2 country code, e.g US
    public let userNickname: String?; // Nikname of user for multi-user integration. Can not be an empty string ("").
    
    public init(
        userIdentifier: String? = nil,
        birthDateYYYYMMDD: String? = nil,
        birthDateYYYYMM: String? = nil,
        birthDateYYYY: String? = nil,
        countryCode: String? = nil,
        userNickname: String? = nil
    ) {
        self.userIdentifier = userIdentifier
        self.birthDateYYYYMMDD = birthDateYYYYMMDD
        self.birthDateYYYYMM = birthDateYYYYMM
        self.birthDateYYYY = birthDateYYYY
        self.countryCode = countryCode
        self.userNickname = userNickname
    }
}


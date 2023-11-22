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
             age: data.age)
    }
    
}

public struct CheckAgeData: Hashable {
    public let userIdentifier: String? ; // uniq user identifier
    public let birthDateYYYYMMDD: String?; // "yyyy-MM-dd" format
    public let birthDateYYYYMM: String? // "2021-03" format
    public let birthDateYYYY: String? // "2021" format
    public let age: Int? // 31, age format
    public let countryCode: String?; // Alpha-2 country code, e.g US
    public let nickname: String?; // Nickname of user for multi-user integration. Can not be an empty string ("").
    
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


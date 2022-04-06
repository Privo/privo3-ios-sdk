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
    let redirectUrl: String?;
    let agId: String?;
    let fpId: String?;
}

public struct CheckAgeData: Hashable {
    let userIdentifier: String? = nil; // uniq user identifier
    let birthDateYYYYMMDD: String? = nil; // "yyyy-MM-dd" format
    let countryCode: String? = nil; // Alpha-2 country code, e.g US
}

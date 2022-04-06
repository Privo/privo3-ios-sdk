//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 05.04.2022.
//

import Foundation

internal struct AgeServiceSettings: Encodable, Decodable {
    let verificationApiKey: String;
    let isGeoApiOn: Bool?;
    let isAllowSelectCountry: Bool?;
}


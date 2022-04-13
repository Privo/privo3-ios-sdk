//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 05.04.2022.
//

import Foundation

internal struct AgeServiceSettings: Encodable, Decodable {
    let isGeoApiOn: Bool
    let isAllowSelectCountry: Bool
    let isProvideUserId: Bool
    let isShowStatusUi: Bool
    let poolAgeGateStatusInterval: Int
    let verificationApiKey: String?
    let p2SiteId: Int?
}


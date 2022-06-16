//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 13.06.2022.
//

import Foundation

struct AgeVerificationStoreData : Encodable, Decodable {
    var displayMode = "redirect"
    let serviceIdentifier: String;
    let redirectUrl: String?;

    let profile: AgeVerificationProfile?;
}


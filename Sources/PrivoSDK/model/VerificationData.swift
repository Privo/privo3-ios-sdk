//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 15.06.2021.
//

import Foundation

struct VerificationData: Encodable {
    let profile: UserVerificationProfile
    let config: VerificationConfig
    var sourceOrigin: String?
    var redirectUrl: String?
}

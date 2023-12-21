//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 13.06.2022.
//

import Foundation

public struct AgeVerificationEvent : Encodable, Decodable {
    
    public let status: AgeVerificationStatus
    
    /// child profile verified by PRIVO
    public let profile: AgeVerificationProfile?
}

struct AgeVerificationEventInternal: Encodable, Decodable {
    let status: AgeVerificationStatusInternal
    let profile: AgeVerificationProfile?
    let ageVerificationId: String?
}

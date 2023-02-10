//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 21.04.2022.
//

import Foundation

internal struct AgeGateEventInternal: Decodable, Encodable, Hashable {
    let status: AgeGateStatusInternal;
    let userIdentifier: String?;
    let agId: String?;
    let ageRange: AgeRange?
}

@available(*, deprecated, message: "We don't store previous events anymore, so we don't need expiration")
internal struct AgeGateExpireEvent: Decodable, Encodable, Hashable {
    let event: AgeGateEvent
    let expires: TimeInterval
}

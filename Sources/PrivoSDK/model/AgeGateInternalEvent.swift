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
}

internal struct AgeGateExpireEvent: Decodable, Encodable, Hashable {
    let event: AgeGateEvent
    let expires: TimeInterval
}

internal struct AgeGateIsExpireEvent: Decodable, Encodable, Hashable {
    let event: AgeGateEvent
    let isExpire: Bool
}

//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.04.2022.
//

import Foundation

public struct AgeGateEvent: Decodable, Encodable, Hashable {
    let status: AgeGateStatus;
    let userIdentifier: String?;
    let agId: String?;
}
public struct AgeGateEventInternal: Decodable, Encodable, Hashable {
    let status: AgeGateStatusInternal;
    let userIdentifier: String?;
    let agId: String?;
}


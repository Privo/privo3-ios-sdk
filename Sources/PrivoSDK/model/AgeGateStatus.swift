//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//

import Foundation

public enum AgeGateAction: Int, Decodable, Encodable, Hashable {
    case Block = 0
    case Consent
    case Verify
    case Allow
}

public struct AgeGateStatus: Decodable, Encodable, Hashable {
    public let action: AgeGateAction
    public let ageGateIdentifier: String
}

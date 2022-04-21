//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 01.04.2022.
//

import Foundation

public struct AgeGateEvent: Decodable, Encodable, Hashable {
    public let status: AgeGateStatus;
    public let userIdentifier: String?;
    public let agId: String?;
}

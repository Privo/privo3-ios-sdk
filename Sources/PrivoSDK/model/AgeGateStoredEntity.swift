//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 31.01.2023.
//

import Foundation

struct AgeGateStoredEntity: Encodable, Decodable, Hashable {
    let userIdentifier: String?
    let nickname: String?
    let agId: String;
}

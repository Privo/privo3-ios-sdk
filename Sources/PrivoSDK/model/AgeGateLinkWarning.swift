//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 31.01.2023.
//

import Foundation

struct AgeGateLinkWarning: Encodable {
    let descripteion: String
    let agIdEntities: Set<AgeGateStoredEntity>
}

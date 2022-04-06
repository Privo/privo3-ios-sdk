//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 05.04.2022.
//

import Foundation

internal struct AgeGateResponse: Decodable, Encodable, Hashable {
    let status: AgeGateAction;
    let ageGateIdentifier: String?;
}

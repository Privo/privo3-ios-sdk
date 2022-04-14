//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 05.04.2022.
//

import Foundation

internal struct AgeGateBirthDateResponse: Decodable, Encodable, Hashable {
    let action: AgeGateAction;
    let ageGateIdentifier: String?;
}
internal struct AgeGateRecheckResponse: Decodable, Encodable, Hashable {
    let action: AgeGateAction;
}

//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 05.04.2022.
//

import Foundation

internal struct AgeGateActionResponse: Decodable, Encodable, Hashable {
    let action: AgeGateAction;
    let agId: String;
}
internal struct AgeGateStatusResponse: Decodable, Encodable, Hashable {
    let status: AgeGateStatusTO;
    let agId: String?;
}

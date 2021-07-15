//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//

import Foundation

struct AgStatusRecord: Decodable, Encodable, Hashable {
    let serviceIdentifier: String
    let agId: String
    let extUserId: String?
    let countryCode: String?
}
struct FpStatusRecord: Decodable, Encodable, Hashable {
    let serviceIdentifier: String
    let fpId: String
    let birthDate: String? // "2021-03-04"
    let extUserId: String?
    let countryCode: String?
}

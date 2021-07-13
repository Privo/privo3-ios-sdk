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
struct BirthDateStatusRecord: Decodable, Encodable, Hashable {
    let serviceIdentifier: String
    let deviceId: String
    let birthDate: String
    let extUserId: String?
    let countryCode: String?
}

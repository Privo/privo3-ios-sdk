//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//

import Foundation


struct FpStatusRecord: Decodable, Encodable, Hashable {
    let serviceIdentifier: String
    let fpId: String
    let birthDate: String? // YYY-MM-DD "2021-03-04"
    let birthDateYYYYMM: String? // "2021-03"
    let birthDateYYYY: String? // "2021"
    let extUserId: String?
    let countryCode: String?
}
struct StatusRecord: Decodable, Encodable, Hashable {
    let serviceIdentifier: String
    let fpId: String
    let agId: String?
    let extUserId: String?
}
struct RecheckStatusRecord: Decodable, Encodable, Hashable {
    let serviceIdentifier: String
    let agId: String
    let birthDate: String? // YYY-MM-DD "2021-03-04"
    let birthDateYYYYMM: String? // "2021-03"
    let birthDateYYYY: String? // "2021"
    let countryCode: String?
}

//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

import Foundation

struct TmpStorageString: Decodable, Encodable {
    let data: String
    let ttl: Int?
}
struct TmpStorageResponse: Decodable {
    let id: String
}


//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 27.08.2021.
//

import Foundation

struct ServiceInfo: Decodable {
    let serviceIdentifier: String
    let apiKeys: Array<String>?
    let authMethods: Array<0>?
    let p2siteId: Int?
}

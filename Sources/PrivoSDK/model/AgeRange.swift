//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 22.09.2022.
//

import Foundation

public struct AgeRange: Decodable, Encodable, Hashable {
    public let start: Int;
    public let end: Int;
    public let jurisdiction: String?;
}

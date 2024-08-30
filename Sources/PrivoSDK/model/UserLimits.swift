//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 29.08.2024.
//

import Foundation

public struct UserLimits: Decodable, Encodable, Hashable {
    public let isOverLimit: Bool
    public let limitYype: LimitType
    public let retryAfter: Int?
}

public enum LimitType: String, Codable {
    case IV
    case Auth
}

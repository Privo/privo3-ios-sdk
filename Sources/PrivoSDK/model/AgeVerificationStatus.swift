//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 13.06.2022.
//

import Foundation

public enum AgeVerificationStatus: String, Decodable, Encodable, Hashable {
    case Undefined = "Undefined"
    case Pending = "Pending"
    case Blocked = "Declined"
    case Allowed = "Confirmed"
    case Canceled = "Canceled"
}

public enum AgeVerificationStatusInternal: String, Decodable, Encodable, Hashable {
    case Undefined = "Undefined"
    case Pending = "Pending"
    case Blocked = "Declined"
    case Allowed = "Confirmed"
    case Canceled = "Canceled"
    case Closed = "Closed"
}


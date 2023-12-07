//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 13.06.2022.
//

import Foundation

/// Please check the Age Verification Status Description [here](https://developer.privo.com/js-sdk/av-js-sdk-methods-statusdescription.html)
public enum AgeVerificationStatus: String, Decodable, Encodable, Hashable {
    case Undefined = "Undefined"
    case Pending = "Pending"
    case Declined = "Declined"
    case Confirmed = "Confirmed"
    case Canceled = "Canceled"
}

public enum AgeVerificationStatusInternal: String, Decodable, Encodable, Hashable {
    case Undefined = "Undefined"
    case Pending = "Pending"
    case Declined = "Declined"
    case Confirmed = "Confirmed"
    case Canceled = "Canceled"
    case Closed = "Closed"
}


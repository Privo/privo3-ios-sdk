//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//

import Foundation


public enum AgeGateStatus: String, Decodable, Encodable, Hashable {
    case Undefined = "Undefined"
    case Blocked = "Blocked"
    case Allowed = "Allowed"
    case Canceled = "Canceled"
    case Pending = "Pending"
    case ConsentApproved="Consent Approved"
    case ConsentDeclined="Consent Declined"
}

public enum AgeGateStatusInternal: String, Decodable, Encodable, Hashable {
    case Undefined = "Undefined"
    case Blocked = "Blocked"
    case Allowed = "Allowed"
    case Canceled = "Canceled"
    case Pending = "Pending"
    case ConsentApproved="Consent Approved"
    case ConsentDeclined="Consent Declined"
    
    // Internal statuses
    case OpenVerification = "open-verification-widget"
    case CloseAgeGate = "close-age-gate-widget"
}

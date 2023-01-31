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
    case Pending = "Pending"
    case ConsentRequired = "ConsentRequired"
    case ConsentApproved = "ConsentApproved"
    case ConsentDenied = "ConsentDenied"
    case IdentityVerificationRequired = "IdentityVerificationRequired"
    case IdentityVerified = "IdentityVerified"
    case AgeVerificationRequired = "AgeVerificationRequired"
    case AgeVerified = "AgeVerified"
    case AgeBlocked = "AgeBlocked"
    case MultiUserBlocked = "MultiUserBlocked"
    case Canceled = "Canceled"
}

public enum AgeGateStatusInternal: String, Decodable, Encodable, Hashable {
    case Undefined = "Undefined"
    case Blocked = "Blocked"
    case Allowed = "Allowed"
    case Pending = "Pending"
    case ConsentRequired = "ConsentRequired"
    case ConsentApproved = "ConsentApproved"
    case ConsentDenied = "ConsentDenied"
    case IdentityVerificationRequired = "IdentityVerificationRequired"
    case IdentityVerified = "IdentityVerified"
    case AgeVerificationRequired = "AgeVerificationRequired"
    case AgeVerified = "AgeVerified"
    case AgeBlocked = "AgeBlocked"
    case Canceled = "Canceled"
    case MultiUserBlocked = "MultiUserBlocked"
    
    // Internal statuses
    case Closed = "Closed"
}



public enum AgeGateStatusTO: Int, Decodable, Encodable, Hashable {
    case Undefined = 0
    case Pending
    case Allowed
    case Blocked
    case ConsentRequired
    case ConsentApproved
    case ConsentDenied
    case IdentityVerificationRequired
    case IdentityVerified
    case AgeVerificationRequired
    case AgeVerified
    case AgeBlocked
    case MultiUserBlocked
}

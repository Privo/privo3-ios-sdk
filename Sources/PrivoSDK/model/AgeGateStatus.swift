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
    case ConsentRequired = "Consent Required"
    case ConsentApproved = "Consent Approved"
    case ConsentDenied = "Consent Denied"
    case IdentityVerificationRequired = "Identity Verification Required"
    case IdentityVerified = "Identity Verified"
    case AgeVerificationRequired = "Age Verification Required"
    case AgeVerified = "Age Verified"
    case AgeBlocked = "Age Blocked"
    case Canceled = "Canceled"
}

public enum AgeGateStatusInternal: String, Decodable, Encodable, Hashable {
    case Undefined = "Undefined"
    case Blocked = "Blocked"
    case Allowed = "Allowed"
    case Pending = "Pending"
    case ConsentRequired = "Consent Required"
    case ConsentApproved = "Consent Approved"
    case ConsentDenied = "Consent Denied"
    case IdentityVerificationRequired = "Identity Verification Required"
    case IdentityVerified = "Identity Verified"
    case AgeVerificationRequired = "Age Verification Required"
    case AgeVerified = "Age Verified"
    case AgeBlocked = "Age Blocked"
    case Canceled = "Canceled"
    
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
}

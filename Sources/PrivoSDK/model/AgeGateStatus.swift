import Foundation

/// Please check the Age Gate Status Description [here](https://developer.privo.com/js-sdk/ag-js-sdk-statusdescription.html).
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
    case AgeEstimationBlocked = "AgeEstimationBlocked"
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
    case AgeEstimationBlocked = "AgeEstimationBlocked"
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
    case AgeEstimationBlocked
}

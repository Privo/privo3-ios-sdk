import Foundation

enum AgeGateStatusInternal: String, Codable {
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

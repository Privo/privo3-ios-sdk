import Foundation

public enum AgeGateStatus: String, Codable {
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

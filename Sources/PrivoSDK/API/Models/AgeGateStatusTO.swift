import Foundation

enum AgeGateStatusTO: Int, Codable {
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


extension AgeGateStatusTO {
    var toStatus: AgeGateStatus {
        switch self {
            case .Pending:
                return .Pending
            case .Allowed:
                return .Allowed
            case .Blocked:
                return .Blocked
            case .ConsentRequired:
                return .ConsentRequired
            case .ConsentApproved:
                return .ConsentApproved
            case .ConsentDenied:
                return .ConsentDenied
            case .IdentityVerificationRequired:
                return .IdentityVerificationRequired
            case .IdentityVerified:
                return .IdentityVerified
            case .AgeVerificationRequired:
                return .AgeVerificationRequired
            case .AgeVerified:
                return .AgeVerified
            case .AgeBlocked:
                return .AgeBlocked
            case .MultiUserBlocked:
                return .MultiUserBlocked
            case .AgeEstimationBlocked:
                return .AgeEstimationBlocked
            default:
                return .Undefined
        }
    }
}

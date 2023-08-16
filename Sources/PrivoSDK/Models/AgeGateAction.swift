import Foundation

public enum AgeGateAction: Int, Codable {
    case Block = 0
    case Consent
    case IdentityVerify
    case AgeVerify
    case Allow
    case MultiUserBlock
    case AgeEstimationBlocked
}

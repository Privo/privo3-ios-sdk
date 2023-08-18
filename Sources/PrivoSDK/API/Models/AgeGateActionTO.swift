import Foundation

public enum AgeGateActionTO: Int, Codable {
    case Block = 0
    case Consent
    case IdentityVerify
    case AgeVerify
    case Allow
    case MultiUserBlock
    case AgeEstimationBlocked
}


extension AgeGateActionTO {
    
    var convertTo: AgeGateAction {
        return .init(rawValue: self.rawValue)!
    }
    
}

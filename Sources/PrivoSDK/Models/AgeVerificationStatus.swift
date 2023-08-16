import Foundation

public enum AgeVerificationStatus: String, Codable {
    case Undefined = "Undefined"
    case Pending = "Pending"
    case Declined = "Declined"
    case Confirmed = "Confirmed"
    case Canceled = "Canceled"
}


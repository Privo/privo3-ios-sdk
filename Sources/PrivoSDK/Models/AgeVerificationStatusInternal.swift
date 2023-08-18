import Foundation

enum AgeVerificationStatusInternal: String, Codable {
    case Undefined = "Undefined"
    case Pending = "Pending"
    case Declined = "Declined"
    case Confirmed = "Confirmed"
    case Canceled = "Canceled"
    case Closed = "Closed"
}

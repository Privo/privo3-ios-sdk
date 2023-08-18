import Foundation

enum AgeVerificationStatusTO: String, Codable {
    case Undefined = "Undefined"
    case Pending = "Pending"
    case Declined = "Declined"
    case Confirmed = "Confirmed"
    case Canceled = "Canceled"
    case Closed = "Closed"
}

extension AgeVerificationStatusTO {
    
    var convertToInternal: AgeVerificationStatusInternal { .init(rawValue: rawValue)! }

}

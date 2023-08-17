import Foundation

enum LoginStatus: String, Codable {
    case AccountLocked
    case ConsentDeclined
    case ConsentPending
    case ConsentPendingNewGranter
    case InvalidCredentials
    case LoginIsNotAllowed
    case MoreDataRequired
    case NewAccount
    case OIDCConsentRequired
    case OK
    case ReAuthenticationRequired
    case UnexpectedError
    case VerificationRequired
}

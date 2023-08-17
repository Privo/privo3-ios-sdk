import Foundation

public enum PrivoError: Error {
    case noInternetConnection
}

public enum AgeGateError: Error {
    case incorrectDateOfBirht
    case incorrectAge
    case notAllowedMultiUserUsage
    case notAllowedEmptyStringUserIdentifier
    case notAllowedEmptyStringNickname
    case notAllowedEmptyStringAgId
}

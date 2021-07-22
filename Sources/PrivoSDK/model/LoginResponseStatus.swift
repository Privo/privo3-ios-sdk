//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 09.06.2021.
//

import Foundation

enum LoginResponseStatus: String, Codable {
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

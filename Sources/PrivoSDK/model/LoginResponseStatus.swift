//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
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

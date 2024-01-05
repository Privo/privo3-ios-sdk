//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public enum PrivoError: Error {
    case noInternetConnection
    case networkConnectionProblem(_ error: Error?)
    
    case cancelled
    case incorrectInputData(_ error: Error)
}

/// Could be a part of the ``PrivoError.incorrectInputData(_)`` error.
public enum AgeGateError: Error {
    case incorrectDateOfBirht
    case incorrectAge
    case notAllowedMultiUserUsage
    case notAllowedEmptyStringUserIdentifier
    case notAllowedEmptyStringNickname
    case notAllowedEmptyStringAgId
    
    /// Attempting to invoke a method for the first time which used agId that has not yet been generated. Try adding a call before the current one so that the method generating agId is called first.
    case agIdNotFound
}

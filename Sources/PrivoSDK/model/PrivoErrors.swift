//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 14.09.2022.
//

import Foundation


public enum PrivoError: Error {
    case noInternetConnection
    case networkConnectionProblem(_ error: Error?)
    
    case cancelled
}

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

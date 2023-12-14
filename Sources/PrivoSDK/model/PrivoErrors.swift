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
    
    case unknown
}

public enum AgeGateError: Error {
    case incorrectDateOfBirht
    case incorrectAge
    case notAllowedMultiUserUsage
    case notAllowedEmptyStringUserIdentifier
    case notAllowedEmptyStringNickname
    case notAllowedEmptyStringAgId
}

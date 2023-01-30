//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 14.09.2022.
//

import Foundation


public enum PrivoError: Error {
    case noInternetConnection
}

public enum AgeGateError: Error {
    case incorrectDateOfBirht
    case notAllowedMultiUserUsage
    case notAllowedEmptyStringUserIdentifier
    case notAllowedEmptyStringNickname
    case notAllowedEmptyStringAgId
}

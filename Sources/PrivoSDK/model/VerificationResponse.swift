//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 21.06.2021.
//

import Foundation

public enum VerificationMethodType: Int, Decodable {
    case CreditCard = 1
    case DriversLicense = 2
    case Phone = 4
    case SSN = 5
    case CorporateEmail = 13
    case PrintForm = 15
    case PayPal = 20
}
public enum VerificationOutcome: Int, Decodable {
    case Pass = 1
    case Pending
    case Fail
    case Declined
    case Purged
}

public struct VerificationResponse: Decodable, Hashable {
    public let verified: Bool
    public let transactionID: String
    public let verificationMethod: VerificationMethodType
    public let matchOutcome: VerificationOutcome
    public let matchCode: String?
    public let requestID: String
    public let redirectUrl: String?
    public let message: String?
    public let partnerDefinedUniqueID: String?
    public let requestTimestamp: Date
    public let locale: String
        //Applicable to offline methods only
    public let identificationNumber: String?
    public let attemptId: Int?
    public let personWithoutCredentialsServiceId: String?
    
}

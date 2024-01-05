//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public enum VerificationMethodType: Int, Decodable {
    case CreditCard = 1
    case DriversLicense = 2
    case Phone = 4
    case SSN = 5
    case CorporateEmail = 6
    case PrintForm = 7
    case PayPal = 10
}
public enum VerificationOutcome: Int, Decodable {
    case Pass = 1
    case Pending
    case Fail
    case Declined
    case Purged
}

public struct VerificationResponse: Decodable, Hashable {
    
    public let requestIdentifier: String
    
    /// User verification status.
    public let verified: Bool
    
    /// Unique identifier for the verification request. The partner should retain this value for traceability.
    public let requestID: String
    
    /// Unique identifier for the transaction. Partner can retain this value for traceability.
    public let transactionID: String
    
    /// The verification method chosen by the user.
    public let verificationMethod: VerificationMethodType
    
    /// Specific outcome for the verification request.
    public let matchOutcome: VerificationOutcome
    
    /// Date of the completed verification request.
    public let requestTimestamp: Date
    
    /// Location of the user as defined by their browser settings.
    public let locale: String
    
    /// A code that identifies the field groups that are matched in the verification request. May be nil.
    public let matchCode: String?
    
    /// Return URL address passed by partner to send the user directly following onVerifyDone event. May be nil.
    public let redirectUrl: String?
    
    /// For debug reasons - if error occurs error message will be provided here. May be nil.
    public let message: String?
    
    /// Value passed by partner in config of the verification request. PRIVO returns this value in the onVerifyComplete event. Can be nil.
    public let partnerDefinedUniqueID: String?

    /// Applicable to offline methods only.
    /// Unique number provided to user when an offline verification method is chosen. This value can be used by Partner and PRIVO to identify the given pending request.
    public let identificationNumber: String?
    
    /// Identifier used to notate the attempt request.
    public let attemptId: Int?
    
    // public let personWithoutCredentialsServiceId: String?
}

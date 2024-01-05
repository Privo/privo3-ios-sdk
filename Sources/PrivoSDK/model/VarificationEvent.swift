//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

public enum VerificationEventType: String, Decodable {
    case verifyInitialized = "verify-initialized"
    case verifyError = "verify-error"
    case verifyPrintPreview = "verify-print-preview"
    case verifyCancel = "verify-cancel"
    case verifyComplete = "verify-complete"
    case verifyDone = "verify-done"
}

public struct VerificationResult: Decodable, Hashable {
    /// If the user has opted to save their verification status by adding a password, then a serviceId will be generated.
    public let serviceId: String?
    
    public let verificationResponse: VerificationResponse
}

public struct VerificationEvent: Decodable, Hashable {
    
    public let event: VerificationEventType
    
    /// Verification result data from PRIVO
    public let result: VerificationResult?
    
    /// The string representation of result object.
    public let data: String?
    
    /// Possible Error Codes
    ///
    /// | Error Code | Error Message |
    /// | ---   | --- |
    /// | 10001 | Invalid API Key or access_token |
    /// | 10002 | Missing site_id parameter |
    /// | 10003 | Unexpected error |
    /// | 10100 | Invalid email address |
    /// | 10101 | Misconfigured verification methods |
    ///
    public let errorCode: String?
    
    public let errorMessage: String?

}

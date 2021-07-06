//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 14.06.2021.
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
    public let verificationResponse: VerificationResponse
}

public struct VerificationEvent: Decodable, Hashable {
    public let event: VerificationEventType
    public let result: VerificationResult?
    public let data: String?
    public let errorCode: String?
    public let errorMessage: String?

}

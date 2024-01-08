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
    
    /// An error that indicates a task was cancelled with `Task.cancel()`.
    ///
    /// Thrown only by those methods that support cancellation and this is explicitly stated in the documentation.
    ///
    /// Cancellation example:
    /// ```swift
    /// let task = Task {
    ///   do {
    ///     let result = try await methodThatSupportsCancellation()
    ///   } catch let privoError as PrivoError {
    ///     if privoError == .cancelled {
    ///       // handle the cancellation
    ///     }
    ///   }
    /// }
    /// ...
    /// // later in code
    /// task.cancel()
    /// ```
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

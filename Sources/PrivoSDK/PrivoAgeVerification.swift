//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

/// ### Age Verification SDK example
///
///     Privo.ageVerification.getStatus(userIdentifier) { response in
///         status = response.status
///     }
///     ...
///     let profile = AgeVerificationProfile(
///       userIdentifier: userIdentifier,
///       firstName: firstName,
///       email: email,
///       birthDateYYYYMMDD: getBirhDate(),
///       phoneNumber: phoneNumber
///     )
///     Privo.ageVerification.run(profile) { response in
///       status = response.status
///     }
///
public class PrivoAgeVerification {
    
    //MARK: - Private properties
    
    private let ageVerification: PrivoAgeVerificationInternal
    
    //MARK: - Public initialisers

    public init() {
        ageVerification = .init()
    }
    
    //MARK: - Public functions
    
    /// The method allows checking the existing Age Verification status.
    /// - Parameters:
    ///   - userIdentifier: External user identifier.
    ///   - completionHandler: Closure which used to handle the result of an asynchronous operation.
    public func getStatus(_ userIdentifier: String? = nil, completionHandler: @escaping (AgeVerificationEvent) -> Void) {
        Task.init(priority: .userInitiated) {
            let event = await ageVerification.getLastEvent(userIdentifier)
            completionHandler(event)
        }
    }
    
    /// The method runs the Age Verification check and returns the status, depending on the user’s age and set by a partner configuration.
    /// - Parameters:
    ///   - profile
    ///   - completionHandler: Closure to execute. Nil indicates a failure has occurred.
    public func run(_ profile: AgeVerificationProfile?, completionHandler: @escaping (AgeVerificationEvent?) -> Void) {
        Task.init {
            let event = await ageVerification.getLastEvent(profile?.userIdentifier)
            if (event.status != .Undefined && event.status != .Canceled) {
                completionHandler(event)
            } else {
                ageVerification.runAgeVerification(profile) { [weak self] event in
                    self?.ageVerification.saveVerificationIdentifier(userIdentifier: profile?.userIdentifier, verificationIdentifier: event?.ageVerificationId)
                    let publicEvent = event?.toEvent
                    completionHandler(publicEvent)
                }
            }
        }
    }
    
    public func hide() {
        ageVerification.hide()
    }
    
}

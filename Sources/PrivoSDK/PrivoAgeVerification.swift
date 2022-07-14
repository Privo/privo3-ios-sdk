//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 14.06.2022.
//

import Foundation

public class PrivoAgeVerification {
    private let ageVerification = PrivoAgeVerificationInternal()

    public init() {
    }
    
    public func getStatus(_ userIdentifier: String? = nil, completionHandler: @escaping (AgeVerificationEvent) -> Void) {
        ageVerification.getLastEvent(userIdentifier, completionHandler: completionHandler)
    }
    
    public func run(
        _ profile: AgeVerificationProfile?,
        completionHandler: @escaping (AgeVerificationEvent?) -> Void
    ) {
        
        ageVerification.getLastEvent(profile?.userIdentifier) { [weak self] event in
            
            if (event.status != AgeVerificationStatus.Undefined &&
                event.status != AgeVerificationStatus.Canceled
            ) {
                completionHandler(event)
            } else {
                self?.ageVerification.runAgeVerification(profile) { event in
                    self?.ageVerification.saveVerificationIdentifier(userIdentifier: profile?.userIdentifier, verificationIdentifier: event?.ageVerificationId)
                    let publicEvent = event?.toEvent()
                    completionHandler(publicEvent)
                }
            }
        }

    }
    public func hide() {
        ageVerification.hide()
    }
}

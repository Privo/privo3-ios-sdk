//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//
import Foundation
import UIKit

public class PrivoAgeGate {
    private let ageGate = InternalPrivoAgeGate()

    public init() {
    }
    
    public func getStatus(
        _ data: CheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
        // TODO: add pooling here
        ageGate.getAgeGateEvent() { lastEvent in
            if (lastEvent != nil && lastEvent?.userIdentifier == data.userIdentifier) {
                completionHandler(lastEvent)
            } else {
                completionHandler(AgeGateEvent(status: AgeGateStatus.Undefined, userIdentifier: nil, agId: nil))
            }
        }
    }
    
    public func run(
        _ data: CheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
        
        let processor = data.birthDateYYYYMMDD != nil ? ageGate.runAgeGateByBirthDay : ageGate.runAgeGate
        
        processor(data) { event in
            if let event = event {
                self.ageGate.storeAgeGateEvent(event)
            }
            completionHandler(event)
        }

    }
    /*
    public func runAgeVerification(ageGateIdentifier: String, completionHandler: @escaping (AgeGateStatus?) -> Void) {
        let profile = UserVerificationProfile(partnerDefinedUniqueID: String(format: "AG:%@", ageGateIdentifier));
        Privo.verification.showVerification(profile) { [weak self] events in
            let status = self?.ageGate.getVerificationResponse(events,ageGateIdentifier: ageGateIdentifier)
            completionHandler(status)
        }
    }
     */
}

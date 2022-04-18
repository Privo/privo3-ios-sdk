//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//
import Foundation
import UIKit

public class PrivoAgeGate {
    private let ageGate = PrivoAgeGateInternal()

    public init() {
    }
    
    public func getStatus(_ userIdentifier: String? = nil, completionHandler: @escaping (AgeGateEvent) -> Void) {
        ageGate.getStatusEvent(userIdentifier) { event in
            self.ageGate.storeAgeGateEvent(event)
            completionHandler(event)
        }
    }
    
    public func run(
        _ data: CheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
        
        ageGate.getAgeGateEvent(data.userIdentifier) { lastEvent in
            
            
            if (lastEvent != nil &&
                lastEvent?.status != AgeGateStatus.ConsentRequired &&
                lastEvent?.status != AgeGateStatus.IdentityVerificationRequired &&
                lastEvent?.status != AgeGateStatus.AgeVerificationRequired
            ) {
                completionHandler(lastEvent)
            } else {
                if (data.birthDateYYYYMMDD != nil) {
                    self.ageGate.runAgeGateByBirthDay(data) { event in
                        self.ageGate.storeAgeGateEvent(event)
                        completionHandler(event)
                    }
                } else {
                    self.ageGate.runAgeGate(data, lastEvent: nil) { event in
                        self.ageGate.storeAgeGateEvent(event)
                        completionHandler(event)
                    }
                }
            }
        }

    }
    public func recheck(
        _ data: RecheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
                
        ageGate.runAgeGateRecheck(data) { event in
            self.ageGate.storeAgeGateEvent(event)
            completionHandler(event)
        }

    }
    public func hide() {
        ageGate.hide()
    }
}

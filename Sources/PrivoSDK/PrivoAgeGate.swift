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
        ageGate.getStatusEvent(userIdentifier, completionHandler: completionHandler)
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
    public func recheck(
        _ data: RecheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
                
        ageGate.runAgeGateRecheck(data) { event in
            if let event = event {
                self.ageGate.storeAgeGateEvent(event)
            }
            completionHandler(event)
        }

    }
    public func hide() {
        ageGate.hide()
    }
}

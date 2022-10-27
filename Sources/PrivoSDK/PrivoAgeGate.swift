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
    
    public func getStatus(_ userIdentifier: String? = nil, completionHandler: @escaping (AgeGateEvent) -> Void) throws {
        try ageGate.helpers.checkNetwork()
        ageGate.getStatusEvent(userIdentifier, completionHandler: completionHandler)
    }
    
    public func run(
        _ data: CheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) throws {
        try ageGate.helpers.checkRequest(data)
        if (data.birthDateYYYYMMDD != nil || data.birthDateYYYYMM != nil || data.birthDateYYYY != nil) {
            ageGate.runAgeGateByBirthDay(data) {  [weak self] event in
                self?.ageGate.storage.storeAgeGateEvent(event)
                completionHandler(event)
            }
        } else {
            ageGate.runAgeGate(data, prevEvent: nil, recheckRequired: false) {  [weak self] event in
                self?.ageGate.storage.storeAgeGateEvent(event)
                completionHandler(event)
            }
        }

    }
    public func recheck(
        _ data: CheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) throws {
        try ageGate.helpers.checkRequest(data)
        if (data.birthDateYYYYMMDD != nil || data.birthDateYYYYMM != nil || data.birthDateYYYY != nil) {
            ageGate.recheckAgeGateByBirthDay(data) { [weak self] event in
                self?.ageGate.storage.storeAgeGateEvent(event)
                completionHandler(event)
            }
        } else {
            ageGate.runAgeGate(data, prevEvent: nil, recheckRequired: true) { [weak self] event in
                self?.ageGate.storage.storeAgeGateEvent(event)
                completionHandler(event)
            }
        }
    }
    public func showIdentifierModal(_ userIdentifier: String? = nil) throws {
        try ageGate.helpers.checkNetwork()
        ageGate.showAgeGateIdentifier(userIdentifier)
    }
    public func hide() {
        ageGate.hide()
    }
}

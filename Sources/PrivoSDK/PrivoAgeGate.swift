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
    
    public func getStatus(userIdentifier: String?, nickname: String? = nil, completionHandler: @escaping (AgeGateEvent) -> Void) throws {
        try ageGate.helpers.checkNetwork()
        try ageGate.helpers.checkUserData(userIdentifier: userIdentifier, nickname: nickname)
        ageGate.getStatusEvent(userIdentifier, nickname: nickname) {  [weak self] event in
            self?.ageGate.storage.storeInfoFromEvent(event: event)
            completionHandler(event)
        }
    }
    
    public func run(
        _ data: CheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) throws {
        try ageGate.helpers.checkRequest(data)
        
        ageGate.getStatusEvent(data.userIdentifier, nickname: data.nickname) {  [weak self] statusEvent in
            self?.ageGate.storage.storeInfoFromEvent(event: statusEvent)
            if (statusEvent.status != AgeGateStatus.Undefined) {
                completionHandler(statusEvent)
            } else {
                if (data.birthDateYYYYMMDD != nil || data.birthDateYYYYMM != nil || data.birthDateYYYY != nil || data.age != nil) {
                    self?.ageGate.runAgeGateByBirthDay(data) { event in
                        self?.ageGate.storage.storeInfoFromEvent(event: event)
                        completionHandler(event)
                    }
                } else {
                    self?.ageGate.runAgeGate(data, prevEvent: nil, recheckRequired: false) { event in
                        self?.ageGate.storage.storeInfoFromEvent(event: event)
                        completionHandler(event)
                    }
                }
            }
        }
    }
    public func recheck(
        _ data: CheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) throws {
        try ageGate.helpers.checkRequest(data)
        if (data.birthDateYYYYMMDD != nil || data.birthDateYYYYMM != nil || data.birthDateYYYY != nil || data.age != nil) {
            ageGate.recheckAgeGateByBirthDay(data) { [weak self] event in
                self?.ageGate.storage.storeInfoFromEvent(event: event)
                completionHandler(event)
            }
        } else {
            ageGate.runAgeGate(data, prevEvent: nil, recheckRequired: true) { [weak self] event in
                self?.ageGate.storage.storeInfoFromEvent(event: event)
                completionHandler(event)
            }
        }
    }
    
    public func linkUser(userIdentifier: String, agId: String, nickname: String?, completionHandler: @escaping (AgeGateEvent) -> Void) throws {
        try ageGate.helpers.checkNetwork()
        try ageGate.helpers.checkUserData(userIdentifier: userIdentifier, nickname: nickname)
        ageGate.linkUser(userIdentifier: userIdentifier, agId: agId, nickname: nickname) {  [weak self] event in
            self?.ageGate.storage.storeInfoFromEvent(event: event)
            completionHandler(event)
        }
    }
    
    public func showIdentifierModal(userIdentifier: String?, nickname: String? = nil) throws {
        try ageGate.helpers.checkNetwork()
        ageGate.showAgeGateIdentifier(userIdentifier: userIdentifier, nickname: nickname)
    }
    public func hide() {
        ageGate.hide()
    }
}

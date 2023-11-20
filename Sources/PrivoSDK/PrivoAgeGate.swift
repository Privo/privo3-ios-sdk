//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//
import Foundation
import UIKit

public class PrivoAgeGate {
    
    private let ageGate: PrivoAgeGateInternal

    public init() {
        ageGate = PrivoAgeGateInternal()
    }
    
    init(urlConfig: URLSessionConfiguration) {
        ageGate = PrivoAgeGateInternal(api: Rest(urlConfig: urlConfig))
    }
    
    public func getStatus(userIdentifier: String?, nickname: String? = nil, completionHandler: @escaping (AgeGateEvent) -> Void) throws {
        Task.init {
            try ageGate.helpers.checkNetwork()
            try ageGate.helpers.checkUserData(userIdentifier: userIdentifier, nickname: nickname)
            let event = await ageGate.getStatusEvent(userIdentifier, nickname: nickname)
            ageGate.storage.storeInfoFromEvent(event: event)
            completionHandler(event)
        }
    }
    
    public func run(_ data: CheckAgeData, completionHandler: @escaping (AgeGateEvent?) -> Void) throws {
        Task.init {
            try ageGate.helpers.checkRequest(data)
            let statusEvent = await ageGate.getStatusEvent(data.userIdentifier, nickname: data.nickname)
            ageGate.storage.storeInfoFromEvent(event: statusEvent)
            if (statusEvent.status != AgeGateStatus.Undefined) {
                completionHandler(statusEvent)
            } else {
                if (data.birthDateYYYYMMDD != nil || data.birthDateYYYYMM != nil || data.birthDateYYYY != nil || data.age != nil) {
                    let newEvent = await ageGate.runAgeGateByBirthDay(data)
                    ageGate.storage.storeInfoFromEvent(event: newEvent)
                    completionHandler(newEvent)
                } else {
                    let event = await ageGate.runAgeGate(data, prevEvent: nil, recheckRequired: nil)
                    ageGate.storage.storeInfoFromEvent(event: event)
                    completionHandler(event)
                }
            }
        }
    }
    
    public func recheck(_ data: CheckAgeData, completionHandler: @escaping (AgeGateEvent?) -> Void) throws {
        Task.init {
            try ageGate.helpers.checkRequest(data)
            if (data.birthDateYYYYMMDD != nil || data.birthDateYYYYMM != nil || data.birthDateYYYY != nil || data.age != nil) {
                let event = await ageGate.recheckAgeGateByBirthDay(data)
                ageGate.storage.storeInfoFromEvent(event: event)
                completionHandler(event)
            } else {
                let event = await ageGate.runAgeGate(data, prevEvent: nil, recheckRequired: .RecheckRequired)
                ageGate.storage.storeInfoFromEvent(event: event)
                completionHandler(event)
            }
        }
    }
    
    public func linkUser(userIdentifier: String, agId: String, nickname: String?, completionHandler: @escaping (AgeGateEvent) -> Void) throws {
        Task.init {
            try ageGate.helpers.checkNetwork()
            try ageGate.helpers.checkUserData(userIdentifier: userIdentifier, nickname: nickname)
            let event = await ageGate.linkUser(userIdentifier: userIdentifier, agId: agId, nickname: nickname)
            ageGate.storage.storeInfoFromEvent(event: event)
            completionHandler(event)
        }
    }
    
    public func showIdentifierModal(userIdentifier: String?, nickname: String? = nil) throws {
        Task.init(priority: .userInitiated) {
            try ageGate.helpers.checkNetwork()
            await ageGate.showAgeGateIdentifier(userIdentifier: userIdentifier, nickname: nickname)
        }
    }
    
    public func hide() {
        Task.init(priority: .userInitiated) {
            await ageGate.hide()
        }
    }
    
}

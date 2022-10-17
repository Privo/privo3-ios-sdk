//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.10.2022.
//

import Foundation

internal class AgeGateStorage {
    private let FP_ID_KEY = "privoFpId";
    private let AGE_EVENT_KEY_PREFIX = "AgeGateEvent"
    private let AGE_GATE_ID_KEY_PREFIX = "AgeGateID"
    
    private let keychain = PrivoKeychain()
    private var lastEvents: [String: AgeGateExpireEvent] = [:]
    
    let serviceSettings = PrivoAgeSettingsInternal()
    
    internal func getAgIdKey(_ userIdentifier: String?) -> String {
        return "\(self.AGE_GATE_ID_KEY_PREFIX)-\(userIdentifier ?? "")"
    }
    
    internal func storeAgeGateEvent(_ event: AgeGateEvent?) {
        
        func getEventExpiration (_ interval: Double) -> TimeInterval {
            if (event?.status == AgeGateStatus.Pending) {
                // Pending Events are always expired and should be re-fetched
                return Date().timeIntervalSince1970
            } else {
                return (Date() + interval).timeIntervalSince1970
            }
        };
        
        if let event = event {
            if (event.status != AgeGateStatus.Canceled) {
                serviceSettings.getSettings { [weak self] settings in
                    let interval = Double(settings.poolAgeGateStatusInterval)
                    let expireEvent = AgeGateExpireEvent(event: event, expires: getEventExpiration(interval))
                    let key = event.userIdentifier ?? ""
                    self?.lastEvents[key] = expireEvent
                }
                if let agId = event.agId {
                    let key = getAgIdKey(event.userIdentifier)
                    keychain.set(key: key, value: agId)
                }
            }
        }
    }
    
    internal func getStoredAgeGateId(_ userIdentifier: String?, completionHandler: @escaping (String?) -> Void) {
        let key = getAgIdKey(userIdentifier)
        let agIdFromKeychain = keychain.get(key)
        if (agIdFromKeychain != nil) {
            completionHandler(agIdFromKeychain)
        } else {
            // follback. TODO: remove it later (after all users will use a new storage)
            let oldKey = "\(AGE_EVENT_KEY_PREFIX)-\(userIdentifier ?? "")"
            if let jsonString = keychain.get(oldKey),
               let jsonData = jsonString.data(using: .utf8),
               let value = try? JSONDecoder().decode(AgeGateExpireEvent.self, from: jsonData),
               let agId = value.event.agId {
                keychain.set(key: key, value: agId) // store agId in the new place
                completionHandler(agId)
             } else {
                 completionHandler(nil)
             }
        }
    }
    
    internal func getStoredAgeGateEvent(_ userIdentifier: String?) -> AgeGateIsExpireEvent? {
        let key = userIdentifier ?? ""
        if let value = lastEvents[key]{
            return AgeGateIsExpireEvent(event: value.event, isExpire: value.expires < Date().timeIntervalSince1970)
        } else {
            return nil
        }
    }
    
    internal func getFpId(completionHandler: @escaping (String) -> Void) {
        if let fpId = keychain.get(FP_ID_KEY) {
            completionHandler(fpId)
        } else {
            let fingerprint = DeviceFingerprint()
            PrivoInternal.rest.generateFingerprint(fingerprint: fingerprint) { [weak self] r in
                if let id = r?.id,
                   let fpIdKey = self?.FP_ID_KEY {
                    self?.keychain.set(key: fpIdKey, value: id)
                    completionHandler(id)
                }
            }
        }
    }
}

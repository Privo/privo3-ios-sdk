//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.10.2022.
//

import Foundation

internal class AgeGateStorage {
    private let FP_ID_KEY = "privoFpId";
    private let AGE_GATE_NIKNAMES_KEY = "AgeGateNiknames"
    private let AGE_EVENT_KEY_PREFIX = "AgeGateEvent"
    private let AGE_GATE_ID_KEY_PREFIX = "AgeGateID"
    
    private let keychain = PrivoKeychain()
    
    let serviceSettings = PrivoAgeSettingsInternal()
    
    internal func getAgIdKey(userIdentifier: String?, nickname: String?) -> String {
        if let nickname = nickname {
            return "\(self.AGE_GATE_ID_KEY_PREFIX)-\(userIdentifier ?? "")-\(nickname)"
        } else {
            return "\(self.AGE_GATE_ID_KEY_PREFIX)-\(userIdentifier ?? "")"
        }
    }
    
    internal func storeInfoFromEvent(event: AgeGateEvent?) {
        if let agId = event?.agId {
            let key = getAgIdKey(userIdentifier: event?.userIdentifier, nickname: event?.nickname)
            keychain.set(key: key, value: agId)
        }
        if let nickname = event?.nickname {
            getStoredNiknames { [weak self] nicknames in
                var newNiknames = nicknames
                newNiknames.insert(nickname)
                if let data = try? JSONEncoder().encode(newNiknames) {
                    let stringData = String(decoding: data, as: UTF8.self)
                    if let keychain = self?.keychain,
                       let AGE_GATE_NIKNAMES_KEY = self?.AGE_GATE_NIKNAMES_KEY {
                        keychain.set(key: AGE_GATE_NIKNAMES_KEY, value: stringData)
                    }
                }
                
            }
        }
    }
    //TODO: we don't need a list of nicknames without age-gate
    internal func getStoredNiknames(completionHandler: @escaping (Set<String>) -> Void) {
        if let jsonString = keychain.get(AGE_GATE_NIKNAMES_KEY),
           let jsonData = jsonString.data(using: .utf8),
           let nicknames = try? JSONDecoder().decode(Set<String>.self, from: jsonData) {
            completionHandler(nicknames)
        } else {
            completionHandler([])
        }
    }
    internal func getIsNicknameStored(completionHandler: @escaping (Bool) -> Void) {
        
    }
    
    
    internal func getStoredAgeGateId(userIdentifier: String?, nickname: String?, completionHandler: @escaping (String?) -> Void) {
        let key = getAgIdKey(userIdentifier: userIdentifier, nickname: nickname)
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

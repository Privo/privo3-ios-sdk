//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.10.2022.
//

import Foundation

internal class AgeGateStorage {
    private let FP_ID_KEY = "privoFpId";
    private let AGE_GATE_STORED_ENTITY_KEY = "AgeGateStoredEntity"
    private let AGE_EVENT_KEY_PREFIX = "AgeGateEvent"
    private let AGE_GATE_ID_KEY_PREFIX = "AgeGateID"
    
    private let keychain = PrivoKeychain()
    
    let serviceSettings = PrivoAgeSettingsInternal()
    
    internal func storeInfoFromEvent(event: AgeGateEvent?) {
        if let agId = event?.agId {
            storeAgId(userIdentifier: event?.userIdentifier, nickname: event?.nickname, agId: agId)
        }
    }
    internal func storeAgId(userIdentifier: String?, nickname: String?, agId: String) {
        let newEntity = AgeGateStoredEntity(userIdentifier: userIdentifier, nickname:nickname, agId: agId)
        getAgeGateStoredEntities { [weak self] entities in
            var newEntities = entities
            newEntities.insert(newEntity)
            if let data = try? JSONEncoder().encode(newEntities) {
                let stringData = String(decoding: data, as: UTF8.self)
                if let keychain = self?.keychain,
                   let AGE_GATE_STORED_ENTITY_KEY = self?.AGE_GATE_STORED_ENTITY_KEY {
                    keychain.set(key: AGE_GATE_STORED_ENTITY_KEY, value: stringData)
                }
            }
        }
    }
    internal func getAgeGateStoredEntities(completionHandler: @escaping (Set<AgeGateStoredEntity>) -> Void) {
        if let jsonString = keychain.get(AGE_GATE_STORED_ENTITY_KEY),
           let jsonData = jsonString.data(using: .utf8),
           let entities = try? JSONDecoder().decode(Set<AgeGateStoredEntity>.self, from: jsonData) {
            completionHandler(entities)
        } else {
            completionHandler([])
        }
    }
    
    internal func getStoredAgeGateId(userIdentifier: String?, nickname: String?, completionHandler: @escaping (String?) -> Void) {
        
        getAgeGateStoredEntities() { [weak self] entities in
            let ageGateData = entities.first(where: { ent in
                if let userIdentifier = userIdentifier {
                    return ent.userIdentifier == userIdentifier
                } else {
                    return ent.nickname == nickname
                }
            })
            if let ageGateData = ageGateData {
                completionHandler(ageGateData.agId)
            } else {
                // fallback 1 TODO: remove it later (after all users will use a new storage)
                if let AGE_GATE_ID_KEY_PREFIX = self?.AGE_GATE_ID_KEY_PREFIX,
                   let AGE_EVENT_KEY_PREFIX = self?.AGE_EVENT_KEY_PREFIX,
                   let keychain = self?.keychain {
                    let oldKey = "\(AGE_GATE_ID_KEY_PREFIX)-\(userIdentifier ?? "")"
                    if let agIdFromKeychain = keychain.get(oldKey) {
                        self?.storeAgId(userIdentifier: userIdentifier, nickname: nickname, agId: agIdFromKeychain) // store agId in the new place
                        completionHandler(agIdFromKeychain)
                    } else {
                        // follback 2. TODO: remove it later (after all users will use a new storage)
                        let oldKey2 = "\(AGE_EVENT_KEY_PREFIX)-\(userIdentifier ?? "")"
                        if let jsonString = keychain.get(oldKey2),
                           let jsonData = jsonString.data(using: .utf8),
                           let value = try? JSONDecoder().decode(AgeGateExpireEvent.self, from: jsonData),
                           let agId = value.event.agId {
                            self?.storeAgId(userIdentifier: userIdentifier, nickname: nickname, agId: agId) // store agId in the new place
                            completionHandler(agId)
                         } else {
                             completionHandler(nil)
                         }
                    }
                }
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

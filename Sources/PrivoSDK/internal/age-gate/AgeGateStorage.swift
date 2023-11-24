//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.10.2022.
//

import Foundation

class AgeGateStorage: IFpIdStorage {
    
    //MARK: - Internal properties
    
    let serviceSettings: PrivoAgeSettingsInternal
    
    //MARK: - Private properties
    
    private let FP_ID_KEY = "privoFpId";
    private let AGE_GATE_STORED_ENTITY_KEY = "AgeGateStoredEntity"
    
    private let keychain: PrivoKeychain
    
    //MARK: - Internal initialisers
    
    init(keyChain: PrivoKeychain = .init(), serviceSettings: PrivoAgeSettingsInternal = .init()) {
        self.keychain = keyChain
        self.serviceSettings = serviceSettings
    }
    
    //MARK: - Internal functions
    
    func getStoredEntitiesKey() -> String {
        return "\(AGE_GATE_STORED_ENTITY_KEY)-\(PrivoInternal.settings.envType)"
    }
    func getFpIdKey() -> String {
        return "\(FP_ID_KEY)-\(PrivoInternal.settings.envType)"
    }
    
    func storeInfoFromEvent(event: AgeGateEvent?) {
        guard let agId = event?.agId else { return }
        storeAgId(userIdentifier: event?.userIdentifier, nickname: event?.nickname, agId: agId)
    }
    
    func storeAgId(userIdentifier: String?, nickname: String?, agId: String) {
        let newEntity = AgeGateStoredEntity(userIdentifier: userIdentifier, nickname:nickname, agId: agId)
        let entities = getAgeGateStoredEntities()
        var newEntities = entities
        newEntities.insert(newEntity)
        guard let data = try? JSONEncoder().encode(newEntities) else { return }
        let stringData = String(decoding: data, as: UTF8.self)
        let key = getStoredEntitiesKey()
        keychain.set(key: key, value: stringData)
    }
    
    func getAgeGateStoredEntities() -> Set<AgeGateStoredEntity> {
        guard let jsonString = keychain.get(getStoredEntitiesKey()),
           let jsonData = jsonString.data(using: .utf8),
           let entities = try? JSONDecoder().decode(Set<AgeGateStoredEntity>.self, from: jsonData) else {
            return []
        }
        return entities
    }
    
    func getStoredAgeGateId(userIdentifier: String?, nickname: String?) -> String? {
        let entities = getAgeGateStoredEntities()
        let ageGateData = entities.first(where: { ent in
            if let userIdentifier = userIdentifier {
                return ent.userIdentifier == userIdentifier
            } else {
                return ent.nickname == nickname
            }
        })
        if let ageGateData = ageGateData { return ageGateData.agId }
        return nil
    }
    
    // MARK: FingerprintStorage
    
    var fpId: String? {
        get {
            return keychain.get(getFpIdKey())
        }
        set {
            if let newValue {
                keychain.set(key: getFpIdKey(), value: newValue)
            } else {
                keychain.delete(getFpIdKey())
            }
        }
    }
}

protocol IFpIdStorage {
    var fpId: String? { get set }
}

protocol FpIdable {
    var fpId: String? { get async }
}

class FpIdService: FpIdable {
    private let source: IRest
    private var storage: IFpIdStorage
    
    init(source: IRest = Rest.shared,
         storage: IFpIdStorage = AgeGateStorage()) {
        self.source = source
        self.storage = storage
    }
    
    var fpId: String? {
        get async {
            return await getFpId()
        }
    }
    
    private func getFpId() async -> String? {
        if let fpId = storage.fpId {
            return fpId
        }
        
        let rawFpId = DeviceFingerprint()
        let fpIdResponse = await source.generateFingerprint(fingerprint: rawFpId)
        
        guard let fpId = fpIdResponse?.id else {
            return nil
        }
        storage.fpId = fpId

        return fpId
    }
}

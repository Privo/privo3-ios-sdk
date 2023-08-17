import Foundation

class PrivoAgeGateStorage {
    
    //MARK: - Internal properties
    
    let serviceSettings: PrivoAgeSettingsService
    
    //MARK: - Private properties
    
    private let FP_ID_KEY = "privoFpId";
    private let AGE_GATE_STORED_ENTITY_KEY = "AgeGateStoredEntity"
    private let AGE_EVENT_KEY_PREFIX = "AgeGateEvent"
    private let AGE_GATE_ID_KEY_PREFIX = "AgeGateID"
    
    private let keychain: PrivoKeychain
    private let api: Rest
    
    //MARK: - Internal initialisers
    
    init(keyChain: PrivoKeychain = .init(), serviceSettings: PrivoAgeSettingsService = .init(), api: Rest = .shared) {
        self.keychain = keyChain
        self.api = api
        self.serviceSettings = serviceSettings
    }
    
    //MARK: - Internal functions
    
    func getStoredEntitiesKey() -> String {
        return "\(AGE_GATE_STORED_ENTITY_KEY)-\(PrivoService.settings.envType)"
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
        guard let stringData = newEntities.convertToString() else { return }
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
        // fallback 1 TODO: remove it later (after all users will use a new storage)
        let oldKey = "\(AGE_GATE_ID_KEY_PREFIX)-\(userIdentifier ?? "")"
        if let agIdFromKeychain = keychain.get(oldKey) {
            storeAgId(userIdentifier: userIdentifier, nickname: nickname, agId: agIdFromKeychain)
            return agIdFromKeychain
        }
        // fallback 2. TODO: remove it later (after all users will use a new storage)
        let oldKey2 = "\(AGE_EVENT_KEY_PREFIX)-\(userIdentifier ?? "")"
        guard let jsonString = keychain.get(oldKey2),
           let jsonData = jsonString.data(using: .utf8),
           let value = try? JSONDecoder().decode(AgeGateExpireEvent.self, from: jsonData),
           let agId = value.event.agId else {
             return nil
         }
        storeAgId(userIdentifier: userIdentifier, nickname: nickname, agId: agId) // store agId in the new place
        return agId
    }
    
    func getFpId() async -> String {
        if let fpId = keychain.get(FP_ID_KEY) { return fpId }
        let response = await api.generateFingerprint(fingerprint: .init())
        //TO DO: need to implement for managing way when there is no id
        guard let id = response?.id else { return "" }
        keychain.set(key: FP_ID_KEY, value: id)
        return id
    }
    
}

//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 21.04.2022.
//

import Foundation
import os.log

class PrivoAgeSettingsInternal {
    private var lastSettings: (String,EnviromentType,AgeServiceSettings)? = nil
    private let api: Rest
    
    init (api: Rest = .shared) {
        self.api = api
        updateSettings() {_ in}
    }
    
    private func updateSettings(_ completion: @escaping (AgeServiceSettings) -> Void) {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        let envType = PrivoInternal.settings.envType
        PrivoInternal.rest.getAgeServiceSettings(serviceIdentifier: serviceIdentifier) { [weak self] s in
            guard let settings = s else {
                os_log("Failed to get privo service settings", log: .default, type: .error)
                return
            }
            self?.lastSettings = (serviceIdentifier,envType,settings)
            completion(settings)
        }
    }
    
    func getSettings(_ completion: @escaping (AgeServiceSettings) -> Void) {
        let envType = PrivoInternal.settings.envType
        if (lastSettings?.0 == PrivoInternal.settings.serviceIdentifier && lastSettings?.1 == envType) {
            if let settings = lastSettings?.2 {
                completion(settings)
            } else {
                updateSettings(completion)
            }
        } else {
            updateSettings(completion)
        }
    }
    
    func getSettingsT(_ completion: @escaping (AgeServiceSettings) throws -> Void) {
        getSettings() { s in
            do {
                try completion(s)
            } catch {
                fatalError("Configuration Error: \(error).")
            }
        }
    }
}

//MARK: - Async Wrappers for functions

extension PrivoAgeSettingsInternal {
    
    func getSettings() async throws -> AgeServiceSettings? {
        let envType = PrivoInternal.settings.envType
        guard lastSettings?.0 == PrivoInternal.settings.serviceIdentifier && lastSettings?.1 == envType else {
            let settings = try await updateSettings()
            return settings
        }
        guard let settings = lastSettings?.2 else {
            let settings = try await updateSettings()
            return settings
        }
        return settings
    }
    
    func getSettingsT() async -> AgeServiceSettings {
        do {
            guard let settings = try await getSettings() else { fatalError("SHOULD BE SETTINGS OBJECT") }
            return settings
        } catch  {
            fatalError("\(#function)\(#line) GET SETTINGS ERROR: \(error).")
        }
    }
    
    private func updateSettings() async throws -> AgeServiceSettings? {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        let envType = PrivoInternal.settings.envType
        let settings = try await api.getAgeServiceSettings(serviceIdentifier: serviceIdentifier)
        guard let settings = settings else {
            os_log("Failed to get privo service settings", log: .default, type: .error)
            fatalError("THERE IS NO OBJECT RELATED TO THE SETTINGS")
        }
        lastSettings = (serviceIdentifier, envType, settings)
        return settings
    }

}

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
    
    init () {
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

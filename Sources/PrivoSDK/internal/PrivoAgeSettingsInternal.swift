//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 21.04.2022.
//

import Foundation
import os.log

class PrivoAgeSettingsInternal {
    private var lastSettings: (String,AgeServiceSettings)? = nil
    
    init () {
        updateSettings() {_ in}
    }
    
    private func updateSettings(_ completion: @escaping (AgeServiceSettings) -> Void) {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        PrivoInternal.rest.getAgeServiceSettings(serviceIdentifier: serviceIdentifier) { s in
            guard let settings = s else {
                os_log("Failed to get privo service settings", log: .default, type: .error)
                return
            }
            self.lastSettings = (serviceIdentifier,settings)
            completion(settings)
        }
    }
    
    func getSettings(_ completion: @escaping (AgeServiceSettings) -> Void) {
        if (lastSettings?.0 == PrivoInternal.settings.serviceIdentifier) {
            if let settings = lastSettings?.1 {
                completion(settings)
            } else {
                updateSettings(completion)
            }
        } else {
            updateSettings(completion)
        }
    }
}

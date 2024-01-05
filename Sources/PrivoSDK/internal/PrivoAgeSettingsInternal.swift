//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import os.log

class PrivoAgeSettingsInternal {
    
    //MARK: - Private properties
    
    private var lastSettings: (String,EnviromentType,AgeServiceSettings)? = nil
    private let api: Restable
    
    //MARK: - Internal initialisers
    
    init (api: Restable = Rest.shared) {
        self.api = api
        Task.detached(priority: .userInitiated) { [weak self] in try? await self?.updateSettings() }
    }
    
    //MARK: - Internal functions
    
    func getSettings() async throws /*(PrivoError)*/ -> AgeServiceSettings {
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
    
    //MARK: - Private functions
    
    private func updateSettings() async throws /*(PrivoError)*/ -> AgeServiceSettings {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        let envType = PrivoInternal.settings.envType
        let settings = try await api.getAgeServiceSettings(serviceIdentifier: serviceIdentifier)
        lastSettings = (serviceIdentifier, envType, settings)
        return settings
    }
    
}

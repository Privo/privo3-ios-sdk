//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 21.04.2022.
//

import Foundation
import os.log

class PrivoAgeSettingsInternal {
    
    //MARK: - Private properties
    
    private var lastSettings: (String,EnviromentType,AgeServiceSettings)? = nil
    private let api: IRest
    
    //MARK: - Internal initialisers
    
    init (api: IRest = Rest.shared) {
        self.api = api
        Task.detached(priority: .userInitiated) { [weak self] in try? await self?.updateSettings() }
    }
    
    //MARK: - Internal functions
    
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
    
    //MARK: - Private functions
    
    private func updateSettings() async throws -> AgeServiceSettings? {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        let envType = PrivoInternal.settings.envType
        let settings = try await api.getAgeServiceSettings(serviceIdentifier: serviceIdentifier)
        guard let settings = settings else {
            os_log("Failed to get privo service settings", log: .default, type: .error)
            return nil
        }
        lastSettings = (serviceIdentifier, envType, settings)
        return settings
    }
    
}

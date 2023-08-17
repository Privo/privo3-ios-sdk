import Foundation
import os.log

class PrivoAgeSettingsService {
    
    //MARK: - Private properties
    
    private var lastSettings: (String,EnviromentType,AgeServiceSettingsResponse)? = nil
    private let api: Rest
    
    //MARK: - Internal initialisers
    
    init(api: Rest = .shared) {
        self.api = api
        Task.detached(priority: .userInitiated) { [weak self] in try? await self?.updateSettings() }
    }
    
    //MARK: - Internal functions
    
    func getSettings() async throws -> AgeServiceSettingsResponse? {
        let envType = PrivoService.settings.envType
        guard lastSettings?.0 == PrivoService.settings.serviceIdentifier && lastSettings?.1 == envType else {
            let settings = try await updateSettings()
            return settings
        }
        guard let settings = lastSettings?.2 else {
            let settings = try await updateSettings()
            return settings
        }
        return settings
    }
    
    func getSettingsT() async -> AgeServiceSettingsResponse {
        do {
            guard let settings = try await getSettings() else { fatalError("SHOULD BE SETTINGS OBJECT") }
            return settings
        } catch {
            fatalError("\(#function)\(#line) GET SETTINGS ERROR: \(error).")
        }
    }
    
    //MARK: - Private functions
    
    private func updateSettings() async throws -> AgeServiceSettingsResponse? {
        let serviceIdentifier = PrivoService.settings.serviceIdentifier
        let envType = PrivoService.settings.envType
        let settings = try await api.getAgeServiceSettings(serviceIdentifier: serviceIdentifier)
        guard let settings = settings else {
            os_log("Failed to get privo service settings", log: .default, type: .error)
            fatalError("THERE IS NO OBJECT RELATED TO THE SETTINGS")
        }
        lastSettings = (serviceIdentifier, envType, settings)
        return settings
    }
    
}

//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

internal class PrivoInternal {
    
    //MARK: - Static properties
        
    static let rest: Restable = Rest()
    
    static private var _configuration: PrivoConfiguration?
    static private var _settings: PrivoSettings?

    //MARK: - Private initialisers
    
    private init () {}
    
    //MARK: - Static functions
    
    static func initialize(settings: PrivoSettings) {
        self._settings = settings
        self._configuration = PrivoConfiguration(type: settings.envType)
    }
    
    static func overrideConfiguration (configuration: PrivoConfiguration) {
        _configuration = configuration
    }
    
    static var configuration: PrivoConfiguration {
        get {
            guard let configuration = PrivoInternal._configuration else {
                preconditionFailure("Privo SDK is not initialized, call Privo.initialize first")
            }
            return configuration
        }
    }
    
    static var settings: PrivoSettings {
        get {
            guard let settings = PrivoInternal._settings else {
                preconditionFailure("Privo SDK is not initialized, call Privo.initialize first")
            }
            return settings
        }
    }
    
}


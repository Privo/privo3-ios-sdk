//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 08.06.2021.
//


internal class PrivoInternal {
    
    //MARK: - Static properties
        
    static let rest = Rest()
    
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


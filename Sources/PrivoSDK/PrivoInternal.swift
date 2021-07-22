//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 08.06.2021.
//


internal class PrivoInternal {
    static private var _configuration: Configuration?
    static private var _settings: PrivoSettings?
    private init () {}
    static func initialize (settings: PrivoSettings) {
        self._settings = settings
        self._configuration = Configuration(type: settings.envType)
    }
    static var configuration: Configuration {
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
    static let rest = Rest();
}


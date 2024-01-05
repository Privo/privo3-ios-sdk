//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

/// You also will need to get credentials from PRIVO to work with this SDK.
///
/// ### Init Privo SDK Sample
///
///   @main
///   struct DemoApp: App {
///     init() {
///       // You can add your settings rirht here
///       Privo.initialize(
///         settings: PrivoSettings(
///                     serviceIdentifier: "{{value}}",
///                     envType: .Int,
///                     apiKey: "{{value}}"
///                   )
///       )
///     }
///     var body: some Scene {
///       WindowGroup {
///         ContentView()
///       }
///     }
///   }
///
public class Privo {
    
    //MARK: - Public properties
    
    public static let auth = PrivoAuth()
    public static let ageGate = PrivoAgeGate.init()
    public static let ageVerification = PrivoAgeVerification()
    public static let verification = PrivoVerification()
    
    public static var getSettings: PrivoSettings {
        return PrivoInternal.settings
    }
    
    //MARK: - Public functions
    
    /// Init PrivoSDK with credentials provided by PRIVO.
    ///
    /// Make sure that you have initialized the PRIVO SDK before any usage of it. It is a good idea to do this immediately after launching the application.
    ///
    ///     Privo.initialize( settings: PrivoSettings(serviceIdentifier: "{{value}}", envType: .Prod,  apiKey: "{{value}}"))
    ///
    /// - Parameter settings
    public static func initialize(settings: PrivoSettings) {
        PrivoInternal.initialize(settings: settings)
    }
    public static func overrideConfiguration (configuration: PrivoConfiguration) {
        PrivoInternal.overrideConfiguration(configuration: configuration)
    }
    
    
    //MARK: - Private initialisers
    
    private init () {}
    

}

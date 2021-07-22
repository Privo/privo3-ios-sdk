//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 20.07.2021.
//

import UIKit
import KeychainAccess

struct DeviceIdentifier {
    public let identifier: String
    private let deviceIdentifierKey = "privo-device-identifier"
    init () throws {
        let keychain = Keychain(service: PrivoInternal.configuration.privoServiceKey)
        if let identifier = keychain[deviceIdentifierKey] {
            self.identifier = identifier
        } else {
            let newIdentifier = UIDevice.current.identifierForVendor!.uuidString
            keychain[deviceIdentifierKey] = newIdentifier
            self.identifier = newIdentifier
        }
    }
}

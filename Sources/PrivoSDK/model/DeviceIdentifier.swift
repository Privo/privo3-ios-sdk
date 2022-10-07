//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 20.07.2021.
//

import UIKit

struct DeviceIdentifier {
    public let identifier: String
    private let deviceIdentifierKey = "privo-device-identifier"
    init () {
        let keychain = PrivoKeychain()
        if let identifier = keychain.get(deviceIdentifierKey) {
            self.identifier = identifier
        } else {
            let newIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            let result = keychain.set(key: deviceIdentifierKey, value: newIdentifier)
            if (result) {
                print("Fail to save user identifier to keychain")
            }
            self.identifier = newIdentifier
        }
    }
}

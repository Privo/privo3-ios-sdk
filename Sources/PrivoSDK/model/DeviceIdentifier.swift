//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
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
            keychain.set(key: deviceIdentifierKey, value: newIdentifier)
            self.identifier = newIdentifier
        }
    }
}

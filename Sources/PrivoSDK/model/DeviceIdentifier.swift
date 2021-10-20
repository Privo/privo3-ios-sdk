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
    
    private static var baseQuery: [String: Any] {
        [kSecAttrService as String: PrivoInternal.configuration.privoServiceKey,
         kSecClass as String: kSecClassGenericPassword]
    }
    
    private static var searchQuery: [String: Any] {
        [kSecMatchLimit as String: kSecMatchLimitOne,
         kSecReturnAttributes as String: true,
         kSecReturnData as String: true]
            .merging(baseQuery, uniquingKeysWith: { (current, _) in current })
    }
    
    init () throws {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(DeviceIdentifier.searchQuery as CFDictionary, &item)
        
        if status != errSecItemNotFound {
            guard let existingItem = item as? [String : Any],
                  let identifierData = existingItem[kSecValueData as String] as? Data,
                  let identifier = String(data: identifierData, encoding: String.Encoding.utf8) else {
                throw KeychainError.unexpectedPasswordData
            }
            self.identifier = identifier
        } else {
            let newIdentifier = UIDevice.current.identifierForVendor!.uuidString
            let addQuery = [kSecValueData as String: newIdentifier].merging(DeviceIdentifier.baseQuery, uniquingKeysWith: { (current, _) in current })
            
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw KeychainError.unhandledError(status: addStatus) }
            self.identifier = newIdentifier
        }
    }
}

enum KeychainError: Error {
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

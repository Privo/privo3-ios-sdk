//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 05.11.2021.
//

import Security
import Foundation
import os.log

struct PrivoKeychain {
    
    //MARK: - Private properties
    
    private let privoPrefix = "com.privo.ios.sdk"
    
    //MARK: - Internal functions
    
    func set (key: String, value: String) {
        delete(key);
        if let data = value.data(using: String.Encoding.utf8) {
            let query: [String : Any] = [
                kSecClass as String         : kSecClassGenericPassword,
                kSecAttrService as String : privoPrefix,
                kSecAttrAccount as String   : key,
                kSecValueData as String     : data
            ]
                  
            let result = SecItemAdd(query as CFDictionary, nil)
            if (result != noErr) {
                os_log("Failed to store value for key %@ in keychain", log: .default, type: .error, key)
            }
        } else {
            os_log("Failed to store value for key %@ in keychain (data-encoding issue)", log: .default, type: .error, key)
        }
    }
    
    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : privoPrefix,
            kSecAttrAccount as String : key,
            kSecMatchLimit as String  : kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]
        var result: AnyObject?
        let resultCode = withUnsafeMutablePointer(to: &result) {
          SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        if resultCode == noErr {
            if let data = result as? Data {
                if let currentString = String(data: data, encoding: .utf8) {
                    return currentString
                }
            }
        }
        return nil
    }
    
    func delete(_ key: String) {
      let query: [String: Any] = [
        kSecClass as String       : kSecClassGenericPassword,
        kSecAttrService as String : privoPrefix,
        kSecAttrAccount as String : key,
      ]
      let response = SecItemDelete(query as CFDictionary)
      if (response != noErr) {
        os_log("Failed to delete value for key %@ in keychain", log: .default, type: .error, key)
      }
    }
}

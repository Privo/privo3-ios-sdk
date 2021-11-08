//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 05.11.2021.
//

import Security
import Foundation

struct PrivoKeychain {
    private let privoPrefix = "com.privo.ios.sdk"
    
    func set (key: String, value: String) -> Bool {
        if let value = value.data(using: String.Encoding.utf8) {
            let prefixedKey = keyWithPrefix(key)
            let query: [String : Any] = [
                kSecClass as String       : kSecClassGenericPassword,
                kSecAttrAccount as String : prefixedKey,
                kSecValueData as String   : value,
                kSecAttrAccessibleWhenUnlocked as String  : kSecAttrAccessibleWhenUnlocked
            ]
                  
            let result = SecItemAdd(query as CFDictionary, nil)
            return result == noErr
        }
        return false
    }
    
    func get(_ key: String) -> String? {
        let prefixedKey = keyWithPrefix(key)
        
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : prefixedKey,
            kSecMatchLimit as String  : kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]
        
        var result: AnyObject?
        
        let resultCode = withUnsafeMutablePointer(to: &result) {
          SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if resultCode == noErr {
            if let data =  result as? Data {
                if let currentString = String(data: data, encoding: .utf8) {
                    return currentString
                }
            }
        }
        return nil;
    }
    
    private func keyWithPrefix(_ key: String) -> String {
        return "\(privoPrefix).\(key)"
    }
}

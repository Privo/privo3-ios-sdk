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
        delete(key);
        if let data = value.data(using: String.Encoding.utf8) {
            let query: [String : Any] = [
                kSecClass as String         : kSecClassGenericPassword,
                kSecAttrService as String : privoPrefix,
                kSecAttrAccount as String   : key,
                kSecValueData as String     : data
            ]
                  
            let result = SecItemAdd(query as CFDictionary, nil)
            return result == noErr
        }
        return false
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
            if let data =  result as? Data {
                if let currentString = String(data: data, encoding: .utf8) {
                    return currentString
                }
            }
        }
        return nil;
    }
    
    func delete(_ key: String) -> Bool {
      
      let query: [String: Any] = [
        kSecClass as String       : kSecClassGenericPassword,
        kSecAttrService as String : privoPrefix,
        kSecAttrAccount as String : key,
      ]
      
      let response = SecItemDelete(query as CFDictionary)
      
      return response == noErr
    }
}

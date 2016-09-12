//
//  KeychainService.swift
//  Stormpath
//
//  Created by Adis on 17/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import Foundation

let AccessTokenKey      = "StormpathAccessToken"
let RefreshTokenKey     = "StormpathRefreshToken"

// Keychain constants

let serviceName             = "StormpathKeychainService"

let SecValueData            = kSecValueData as String
let SecAttrAccessible       = kSecAttrAccessible as String
let SecClass                = kSecClass as String
let SecAttrService          = kSecAttrService as String
let SecAttrGeneric          = kSecAttrGeneric as String
let SecAttrAccount          = kSecAttrAccount as String
let SecMatchLimit           = kSecMatchLimit as String
let SecReturnData           = kSecReturnData as String

class KeychainService {
    var prefix: String
    
    init(withIdentifier identifier: String) {
        self.prefix = identifier
    }
    
    // Convenience vars
    
    var accessToken: String? {
        get {
            return stringForKey(AccessTokenKey)
        }
        
        set {
            saveString(newValue, key: AccessTokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            return stringForKey(RefreshTokenKey)
        }
        
        set {
            saveString(newValue, key: RefreshTokenKey)
        }
    }
    
    // MARK: Core methods
    
    func saveString(_ value: String?, key keyWithoutPrefix: String) {
        let key = prefix + keyWithoutPrefix
        guard let value = value else {
            deletestringForKey(key)
            return
        }
        
        var keychainQueryDictionary: [String: Any] = keychainQueryDictionaryForKey(key)
        
        keychainQueryDictionary[SecValueData] = value.data(using: String.Encoding.utf8)
        keychainQueryDictionary[SecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        
        let status: OSStatus = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
        
        // If the value exists, update it instead
        if status == errSecDuplicateItem {
            updateValue(value, key: key)
        } else if status != errSecSuccess {
            Logger.log("Couldn't store value \(value) to keychain")
        }
    }
    
    func stringForKey(_ keyWithoutPrefix: String) -> String? {
        let key = prefix + keyWithoutPrefix
        var keychainQueryDictionary: [String: Any] = keychainQueryDictionaryForKey(key)
        var result: AnyObject?
    
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        keychainQueryDictionary[SecReturnData] = kCFBooleanTrue
        
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(keychainQueryDictionary as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if status == noErr {
            var stringValue: String?
            if let data = result as? Data {
                stringValue = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
                return stringValue
            }
        }
        
        return nil
    }
    
    // MARK: Keychain access helpers
    
    private func updateValue(_ value: String, key: String) {
        let keychainQueryDictionary: [String: Any] = keychainQueryDictionaryForKey(key)
        
        let valueData = value.data(using: String.Encoding.utf8)
        let updateDictionary: NSDictionary = [SecValueData: valueData!]
        
        SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary)
    }
	
    @discardableResult
    private func deletestringForKey(_ key: String) -> Bool {
        let keychainQueryDictionary: [String: Any] = keychainQueryDictionaryForKey(key)
        
        let status: OSStatus =  SecItemDelete(keychainQueryDictionary as CFDictionary);
        
        return status == errSecSuccess
    }
    
    // MARK: Keychain query dictionary
    
    private func keychainQueryDictionaryForKey(_ key: String) -> [String: Any] {
        var keychainQueryDictionary: [String: Any] = [String: AnyObject]()
        
        keychainQueryDictionary[SecClass] = kSecClassGenericPassword
        keychainQueryDictionary[SecAttrService] = serviceName
        
        let identifier: Data? = key.data(using: String.Encoding.utf8)
        keychainQueryDictionary[SecAttrGeneric] = identifier
        keychainQueryDictionary[SecAttrAccount] = identifier
        
        return keychainQueryDictionary
    }
    
}

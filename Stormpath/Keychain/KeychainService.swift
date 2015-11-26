//
//  KeychainService.swift
//  Stormpath
//
//  Created by Adis on 17/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit
import Foundation

let accessTokenKey: String      = "StormpathAccessTokenKey"
let refreshTokenKey: String     = "StormpathRefreshTokenKey"
let APIURLKey: String           = "StormpathAPIURLKey"

// Keychain constants

let serviceName: String         = "StormpathKeychainService"

let SecValueData: String        = kSecValueData as String
let SecAttrAccessible: String   = kSecAttrAccessible as String
let SecClass: String            = kSecClass as String
let SecAttrService: String      = kSecAttrService as String
let SecAttrGeneric: String      = kSecAttrGeneric as String
let SecAttrAccount: String      = kSecAttrAccount as String

internal class KeychainService: NSObject {
    
    // Convenience vars
    
    internal class var accessToken: String? {
        get {
            return self.dataForKey(accessTokenKey)
        }
        
        set {
            self.saveData(newValue, key: accessTokenKey)
        }
    }
    
    internal class var refreshToken: String? {
        get {
            return self.dataForKey(refreshTokenKey)
        }
        
        set {
            self.saveData(newValue, key: refreshTokenKey)
        }
    }
    
    internal class var APIURL: String? {
        get {
            return self.dataForKey(APIURLKey)
        }
        
        set {
            self.saveData(newValue, key: APIURLKey)
        }
    }
    
    // MARK: Core methods
    
    internal class func saveData(data: String?, key: String) {
        guard data != nil else {
            self.deleteDataForKey(key)
            return
        }
        
        var keychainQueryDictionary: Dictionary<String, AnyObject> = self.keychainQueryDictionaryForKey(key)
        keychainQueryDictionary[SecValueData] = data
        keychainQueryDictionary[SecAttrAccessible] = kSecClassGenericPassword as String
        
        let status: OSStatus = SecItemAdd(keychainQueryDictionary, nil)
        
        // If the value exists, update it instead
        if (status == errSecDuplicateItem) {
            self.updateData(data!, key: key)
        }
    }
    
    internal class func dataForKey(key: String) -> String? {
        if let data: String = NSUserDefaults.standardUserDefaults().objectForKey(key) as? String {
            return data
        } else {
            return nil
        }
    }
    
    // MARK: Keychain access helpers
    
    internal class func updateData(data: String, key: String) {
        let keychainQueryDictionary: Dictionary<String, AnyObject> = self.keychainQueryDictionaryForKey(key)
        let updateDictionary = [SecValueData: data]
        
        SecItemUpdate(keychainQueryDictionary, updateDictionary)
    }
    
    internal class func deleteDataForKey(key: String) -> Bool {
        let keychainQueryDictionary: Dictionary<String, AnyObject> = self.keychainQueryDictionaryForKey(key)
        
        let status: OSStatus =  SecItemDelete(keychainQueryDictionary);
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    internal class func keychainQueryDictionaryForKey(key: String) -> Dictionary<String, AnyObject> {
        var keychainQueryDictionary: Dictionary<String, AnyObject> = [SecClass: kSecClassInternetPassword]
        keychainQueryDictionary[SecAttrService] = serviceName
        
        // Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier: NSData? = key.dataUsingEncoding(NSUTF8StringEncoding)
        
        keychainQueryDictionary[SecAttrGeneric] = encodedIdentifier
        keychainQueryDictionary[SecAttrAccount] = encodedIdentifier
        
        return keychainQueryDictionary
    }
    
}

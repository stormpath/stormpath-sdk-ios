//
//  KeychainService.swift
//  Stormpath
//
//  Created by Adis on 17/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit
import Foundation

let AccessTokenKey: String      = "StormpathAccessTokenKey"
let RefreshTokenKey: String     = "StormpathRefreshTokenKey"
let APIURLKey: String           = "StormpathAPIURLKey"

// Keychain constants

let serviceName: String             = "StormpathKeychainService"

let SecValueData: String            = kSecValueData as String
let SecAttrAccessible: String       = kSecAttrAccessible as String
let SecClass: String                = kSecClass as String
let SecAttrService: String          = kSecAttrService as String
let SecAttrGeneric: String          = kSecAttrGeneric as String
let SecAttrAccount: String          = kSecAttrAccount as String
let SecMatchLimit: String           = kSecMatchLimit as String
let SecReturnData: String           = kSecReturnData as String

internal class KeychainService: NSObject {
    
    // Convenience vars
    
    internal class var accessToken: String? {
        get {
            return stringForKey(AccessTokenKey)
        }
        
        set {
            saveString(newValue, key: AccessTokenKey)
        }
    }
    
    internal class var refreshToken: String? {
        get {
            return stringForKey(RefreshTokenKey)
        }
        
        set {
            saveString(newValue, key: RefreshTokenKey)
        }
    }
    
    internal class var APIURL: String? {
        get {
            return stringForKey(APIURLKey)
        }
        
        set {
            saveString(newValue, key: APIURLKey)
        }
    }
    
    // MARK: Core methods
    
    internal class func saveString(value: String?, key: String) {
        guard value != nil else {
            deletestringForKey(key)
            return
        }
        
        var keychainQueryDictionary: [String: AnyObject] = keychainQueryDictionaryForKey(key)
        
        keychainQueryDictionary[SecValueData] = value!.dataUsingEncoding(NSUTF8StringEncoding)
        keychainQueryDictionary[SecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        
        let status: OSStatus = SecItemAdd(keychainQueryDictionary, nil)
        
        // If the value exists, update it instead
        if status == errSecDuplicateItem {
            updateValue(value!, key: key)
        } else if status != errSecSuccess {
            // ADD LOG
        }
    }
    
    internal class func stringForKey(key: String) -> String? {
        var keychainQueryDictionary: [String: AnyObject] = keychainQueryDictionaryForKey(key)
        var result: AnyObject?
    
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        keychainQueryDictionary[SecReturnData] = kCFBooleanTrue
        
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(keychainQueryDictionary, UnsafeMutablePointer($0))
        }
        
        if status == noErr {
            var stringValue: String?
            if let data = result as? NSData {
                stringValue = NSString(data: data, encoding: NSUTF8StringEncoding) as String?
                return stringValue
            }
        }
        
        return nil
    }
    
    // MARK: Keychain access helpers
    
    internal class func updateValue(value: String, key: String) {
        let keychainQueryDictionary: [String: AnyObject] = keychainQueryDictionaryForKey(key)
        
        let valueData = value.dataUsingEncoding(NSUTF8StringEncoding)
        let updateDictionary: NSDictionary = [SecValueData: valueData!]
        
        SecItemUpdate(keychainQueryDictionary, updateDictionary)
    }
    
    internal class func deletestringForKey(key: String) -> Bool {
        let keychainQueryDictionary: [String: AnyObject] = keychainQueryDictionaryForKey(key)
        
        let status: OSStatus =  SecItemDelete(keychainQueryDictionary);
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Keychain query dictionary
    
    internal class func keychainQueryDictionaryForKey(key: String) -> [String: AnyObject] {
        var keychainQueryDictionary: [String: AnyObject] = [String: AnyObject]()
        
        keychainQueryDictionary[SecClass] = kSecClassGenericPassword
        keychainQueryDictionary[SecAttrService] = serviceName
        
        let identifier: NSData? = key.dataUsingEncoding(NSUTF8StringEncoding)
        keychainQueryDictionary[SecAttrGeneric] = identifier
        keychainQueryDictionary[SecAttrAccount] = identifier
        
        return keychainQueryDictionary
    }
    
}

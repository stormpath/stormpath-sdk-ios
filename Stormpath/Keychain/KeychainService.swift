//
//  KeychainService.swift
//  Stormpath
//
//  Created by Adis on 17/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

let accessTokenKey: String      = "StormpathAccessTokenKey"
let refreshTokenKey: String     = "StormpathRefreshTokenKey"
let APIURLKey: String           = "StormpathAPIURLKey"

internal class KeychainService: NSObject {
    
    // Convenience vars
    
    internal class var accessToken: String? {
        get {
            return KeychainService.dataForKey(accessTokenKey)
        }
        
        set {
            KeychainService.save(newValue, key: accessTokenKey)
        }
    }
    
    internal class var refreshToken: String? {
        get {
            return KeychainService.dataForKey(refreshTokenKey)
        }
        
        set {
            KeychainService.save(newValue, key: refreshTokenKey)
        }
    }
    
    internal class var APIURL: String? {
        get {
            return KeychainService.dataForKey(APIURLKey)
        }
        
        set {
            KeychainService.save(newValue, key: APIURLKey)
        }
    }
    
    // This class does not yet use the keychain, will do in the future
    
    internal class func save(data: String?, key: String?) {
        guard data != nil && key != nil else {
            return
        }
        
        // FIXME: Use real keychain
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: key!)
    }
    
    internal class func dataForKey(key: String) -> String? {
        if let data: String = NSUserDefaults.standardUserDefaults().objectForKey(key) as? String {
            return data
        } else {
            return nil
        }
    }
    
}

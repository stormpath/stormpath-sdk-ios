//
//  Stormpath.swift
//  Stormpath
//
//  Created by Adis on 16/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

public typealias CompletionBlock = ((Bool, NSError!) -> Void)!

let APIKeyKeychainKey: String    = "APIKeyKeychainKey"
let APISecretKeychainKey: String = "APISecretKeychainKey"
let APIURLKeychainKey: String    = "APIURLKeychainKey"

public class Stormpath: NSObject {
    
    // MARK: Init
    
    public override init() {
        super.init()
    }
    
    // MARK: Initial setup
    
    public class var APIKey: String {
        get {
            return KeychainService.loadData(APIKeyKeychainKey)
        }
        
        set {
            KeychainService.save(newValue, key: APIKeyKeychainKey)
        }
    }
    
    public class var secret: String {
        get {
            return KeychainService.loadData(APISecretKeychainKey)
        }
        
        set {
            KeychainService.save(newValue, key: APISecretKeychainKey)
        }
    }
    
    public class var APIURL: String {
        get {
            return KeychainService.loadData(APIURLKeychainKey)
        }
        
        set {
            KeychainService.save(newValue, key: APIURLKeychainKey)
        }
    }
    
    // MARK: Basic user management
    
    public class func register(username: String, password: String, completion: CompletionBlock) {
        
        APIService.register(username, password: password, completion: completion)
        
    }
    
    public class func login(username: String, password: String, completion: CompletionBlock) {
        
        APIService.login(username, password: password, completion: completion)
        
    }
    
    public class func logout(completion: CompletionBlock) {
        
        APIService.logout(completion)
        
    }
    
    public class func resetPassword() {
        
    }
    
    // MARK: Token handling
    
    public class func accessToken() -> String {
        return ""
    }
    
    public class func refreshAccesToken() {
        
    }
    
}

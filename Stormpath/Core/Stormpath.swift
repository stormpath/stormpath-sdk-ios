//
//  Stormpath.swift
//  Stormpath
//
//  Created by Adis on 16/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

public typealias CompletionBlockWithDictionary = ((NSDictionary?, NSError?) -> Void)
public typealias CompletionBlockWithError      = ((NSError?) -> Void)

let APIKeyKeychainKey: String    = "APIKeyKeychainKey"
let APISecretKeychainKey: String = "APISecretKeychainKey"
let APIURLKeychainKey: String    = "APIURLKeychainKey"

public class Stormpath: NSObject {
    
    // MARK: Initial setup
    
    public class func setUpWithURL(APIURL: String, APIKey: String, APISecret: String) {
        Stormpath.APIURL    = APIURL
        Stormpath.APIKey    = APIKey
        Stormpath.APISecret = APISecret
    }
    
    // API vars
    
    class var APIKey: String {
        get {
            return KeychainService.loadData(APIKeyKeychainKey)
        }
        
        set {
            KeychainService.save(newValue, key: APIKeyKeychainKey)
        }
    }
    
    class var APISecret: String {
        get {
            return KeychainService.loadData(APISecretKeychainKey)
        }
        
        set {
            KeychainService.save(newValue, key: APISecretKeychainKey)
        }
    }
    
    class var APIURL: String {
        get {
            return KeychainService.loadData(APIURLKeychainKey)
        }
        
        set {
            KeychainService.save(newValue, key: APIURLKeychainKey)
        }
    }
    
    // MARK: User registration
    
    public class func register(username: String, password: String, completion: CompletionBlockWithDictionary) {
        
        let userDictionary: NSDictionary = ["email": username, "password": password]
        APIService.register(userDictionary, completion: completion)
        
    }
    
    public class func register(userDictionary: NSDictionary, completion: CompletionBlockWithDictionary) {
        
        APIService.register(userDictionary, completion: completion)
        
    }
    
    // MARK: User login
    
    public class func login(username: String, password: String, completion: CompletionBlockWithDictionary) {
        
        APIService.login(username, password: password, completion: completion)
        
    }
    
    // MARK: User logout
    
    public class func logout(completion: CompletionBlockWithError) {
        
        APIService.logout(completion)
        
    }
    
    // MARK: User password reset
    
    public class func resetPassword() {
        
    }
    
    // MARK: Token management
    
    public class func accessToken() -> String {
        return ""
    }
    
    public class func refreshAccesToken() {
        
    }
    
}

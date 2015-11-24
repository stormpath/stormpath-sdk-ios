//
//  Stormpath.swift
//  Stormpath
//
//  Created by Adis on 16/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

public typealias CompletionBlockWithDictionary = ((NSDictionary?, NSError?) -> Void)
public typealias CompletionBlockWithString     = ((NSString?, NSError?) -> Void)
public typealias CompletionBlockWithError      = ((NSError?) -> Void)

public final class Stormpath: NSObject {
    
    // MARK: Initial setup
    
    /**
    Use this method for the initial setup for your Stormpath backend.
    
    - parameter APIURL: The base URL of your API, eg. "https://api.stormpath.com". The trailing slash is unnecessary.
    */
    public class func setUpWithURL(APIURL: String) {
        // TODO: Add guards
        
        // Trim the trailing slash if needed
        if APIURL.hasSuffix("/") {
            Stormpath.APIURL = String(APIURL.characters.dropLast())
        } else {
            Stormpath.APIURL = APIURL
        }
    }
    
    // API vars
    
    internal class var APIURL: String {
        get {
            return KeychainService.APIURL
        }
        
        set {
            KeychainService.APIURL = newValue
        }
    }
    
    // MARK: User registration
    
    /**
     This method registers a user from the data provided.
     
     - parameter customPath: Relative path for your register.
     - parameter userDictionary: User data in the form of a dictionary. Check the docs for more info: http://docs.stormpath.com/rest/product-guide/#create-an-account
     - parameter completion: The completion block to be invoked after the API request is finished. It returns a dictionary with user data,
        or an error if one occured.
     */
    
    public class func register(customPath: String, userDictionary: NSDictionary, completion: CompletionBlockWithDictionary) {
        
        APIService.register(customPath, userDictionary: userDictionary, completion: completion)
        
    }
    
    /**
     This method registers a user from the data provided, and assumes the standard register path - /register.
     
     - parameter userDictionary: User data in the form of a dictionary. Check the docs for more info: http://docs.stormpath.com/rest/product-guide/#create-an-account
     - parameter completion: The completion block to be invoked after the API request is finished. It returns a dictionary with user data,
        or an error if one occured.
     */
    
    public class func register(userDictionary: NSDictionary, completion: CompletionBlockWithDictionary) {
        
        APIService.register(nil, userDictionary: userDictionary, completion: completion)
        
    }
    
    // MARK: User login
    
    /**
    Logs in a user and assumes that the login path is behind the /login relative path. This method also stores the user session tokens for later use.
    
    - parameter username: User username.
    - parameter password: User password.
    - parameter completion: The completion block to be invoked after the API request is finished. If the method fails, the error will be passed in the completion.
    */
    
    public class func login(username: String, password: String, completion: CompletionBlockWithString) {
        
        APIService.login(nil, username: username, password: password, completion: completion)
        
    }
    
    // MARK: User logout
    
    /**
    Logs out the user and clears the sessions tokens.
    
    - parameter completion: The completion block to be invoked after the API request is finished. If the method fails, the error will be passed in the completion.
    */

    
    public class func logout(completion: CompletionBlockWithError) {
        
        APIService.logout(nil, completion: completion)
        
    }
    
    // MARK: User password reset
    
    public class func resetPassword() {
        
    }
    
    // MARK: Token management
    
    public class func accessToken() -> String {
        return KeychainService.accessToken
    }
    
    public class func refreshAccesToken() {
        
    }
    
}

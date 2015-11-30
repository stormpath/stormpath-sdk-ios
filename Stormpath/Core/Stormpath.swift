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
    
    // API vars
    
    internal class var APIURL: String? {
        get {
            return KeychainService.APIURL
        }
        
        set {
            KeychainService.APIURL = newValue
        }
    }
    
    // MARK: Initial setup
    
    /**
    Use this method for the initial setup for your Stormpath backend.
    
    - parameter APIURL: The base URL of your API, eg. "https://api.stormpath.com". The trailing slash is unnecessary.
    */
    public class func setUpWithURL(APIURL: String) {
        // TODO: Add guards
        
        // Trim the trailing slash if needed
        if APIURL.hasSuffix("/") {
            self.APIURL = String(APIURL.characters.dropLast())
        } else {
            self.APIURL = APIURL
        }
    }
    
    // MARK: User registration
    
    /**
     This method registers a user from the data provided.
     
     - parameter customPath: Relative path for your register. Pass nil if you don't use custom routes.
     - parameter userDictionary: User data in the form of a dictionary. Check the docs for more info: http://docs.stormpath.com/rest/product-guide/#create-an-account
     - parameter completion: The completion block to be invoked after the API request is finished. It returns a dictionary with user data,
        or an error if one occured.
     */
    
    public class func register(customPath: String?, userDictionary: Dictionary<String, String>, completion: CompletionBlockWithDictionary) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.register(customPath, userDictionary: userDictionary, completion: completion)
        
    }
    
    // MARK: User login
    
    /**
    Logs in a user and assumes that the login path is behind the /login relative path. This method also stores the user session tokens for later use.
    
    - parameter customPath: Relative path for your login. Pass nil if you don't use custom routes.
    - parameter username: User username.
    - parameter password: User password.
    - parameter completion: The completion block to be invoked after the API request is finished. If the method fails, the error will be passed in the completion.
    */
    
    public class func login(customPath: String?, username: String, password: String, completion: CompletionBlockWithString) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.login(customPath, username: username, password: password, completion: completion)
        
    }
    
    // MARK: User logout
    
    /**
    Logs out the user and clears the sessions tokens.
    
    - parameter completion: The completion block to be invoked after the API request is finished. If the method fails, the error will be passed in the completion.
    */

    
    public class func logout(completion: CompletionBlockWithError) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.logout(nil, completion: completion)
        
    }
    
    // MARK: User password reset
    
    /**
    Generates a user password reset token and sends an email to the user, if such email exists.
    
    - parameter email: User email. Usually from an input.
    - parameter completion: The completion block to be invoked after the API request is finished. If there were errors, they will be passed in the completion block.
    */
    
    public class func resetPassword(customPath: String?, email: String, completion: CompletionBlockWithError) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.resetPassword(customPath, email: email, completion: completion)
        
    }
    
    // MARK: Token management
    
    /**
    Provides the last access token fetched by either login or refreshAccessToken functions.
    
    - returns: Access token for your API calls.
    */
    
    public class var accessToken: String? {
        
        get {
            return KeychainService.accessToken
        }
        
    }
    
    /**
     Refreshes the access token and stores it to be available via accessToken var. Call this function if your token expires.
     
     - parameter completion: Block invoked on function completion. It will have either a new access token passed as a string, or an error if one occured.
     */
    
    public class func refreshAccesToken(customPath: String?, completion: CompletionBlockWithString) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.refreshAccessToken(customPath, completion: completion)
        
    }
    
    /**
     Sets the log level to enable console output of network requests to your API.
     
     - parameter level: Level of logging, defaults to None. Info will log all of the request and response data. Error will only log if there was a critical issue.
     */
     
    public class func setLogLevel(level: LogLevel) {
        
    }
    
    /**
     Clean up all saved data. This is used for testing only.
     */
    
    internal class func cleanUp() {
        
        Stormpath.APIURL = nil
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil
        
    }
    
}

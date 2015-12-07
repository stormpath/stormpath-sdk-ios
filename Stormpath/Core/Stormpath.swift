//
//  Stormpath.swift
//  Stormpath
//
//  Created by Adis on 16/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

public typealias CompletionBlockWithDictionary = ((NSDictionary?, NSError?) -> Void)
public typealias CompletionBlockWithString     = ((String?, NSError?) -> Void)
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
     
     - parameter customPath: Relative path for your register. Can be omitted.
     - parameter userDictionary: User data in the form of a dictionary. Check the docs for more info: http://docs.stormpath.com/rest/product-guide/#create-an-account
     - parameter completion: The completion block to be invoked after the API request is finished. It returns a dictionary with user data,
        or an error if one occured.
     */
    
    public class func register(customPath: String? = nil, userDictionary: Dictionary<String, String>, completion: CompletionBlockWithDictionary) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.register(customPath, userDictionary: userDictionary, completion: completion)
        
    }
    
    // MARK: User login
    
    /**
    Logs in a user and assumes that the login path is behind the /login relative path. This method also stores the user session tokens for later use.
    
    - parameter customPath: Relative path for your login. Pass nil or ommit if you didn't change custom routes.
    - parameter username: User username.
    - parameter password: User password.
    - parameter completion: The completion block to be invoked after the API request is finished. If the method fails, the error will be passed in the completion.
    */
    
    public class func login(customPath: String? = nil, username: String, password: String, completion: CompletionBlockWithString) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.login(customPath, username: username, password: password, completion: completion)
        
    }
    
    // MARK: User logout
    
    /**
    Logs out the user and clears the sessions tokens.
    
    - parameter customPath: Relative path for logout. Omit if not used.
    - parameter completion: The completion block to be invoked after the API request is finished. If the method fails, the error will be passed in the completion.
    */

    
    public class func logout(customPath: String? = nil, completion: CompletionBlockWithError) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.logout(customPath, completion: completion)
        
    }
    
    // MARK: User password reset
    
    /**
    Generates a user password reset token and sends an email to the user, if such email exists.
    
    - parameter customPath: Custom path to your forgot password. Omit if not changed from default.
    - parameter email: User email. Usually from an input.
    - parameter completion: The completion block to be invoked after the API request is finished. If there were errors, they will be passed in the completion block.
    */
    
    public class func resetPassword(customPath: String? = nil, email: String, completion: CompletionBlockWithError) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.resetPassword(customPath, email: email, completion: completion)
        
    }
    
    // MARK: Token management
    
    /**
    Provides the last access token fetched by either login or refreshAccessToken functions. NOTE: This value might be expired, to make sure you always have the valid token, use the accessToken() method.
    
    - returns: Access token for your API calls.
    */
    
    public class var accessToken: String? {
        
        get {
            return KeychainService.accessToken
        }
        
    }
    
    /**
     Returns the token immediately if it's not expired and if there's one available, otherwise refreshes the token and returns the refreshed value.
     
     - parameter completion: Block invoked when the token is fetched. The string will either contain the token, or there will be an error passed if something went wrong.
     */
    
    public class func accessToken(completion: CompletionBlockWithString) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.accessTokenWithCompletion(completion)
        
    }
    
    /**
     Refreshes the access token and stores it to be available via accessToken var. Call this function if your token expires.
     
     - parameter customPath: Relative path to your *login* call, omit if login was not changed in the config.
     - parameter completion: Block invoked on function completion. It will have either a new access token passed as a string, or an error if one occured.
     */
    
    public class func refreshAccesToken(customPath: String? = nil, completion: CompletionBlockWithString) {
        
        assert(self.APIURL != nil, "Please set up the API URL with Stormpath.setUpWithURL() function")
        APIService.refreshAccessToken(customPath, completion: completion)
        
    }
    
    /**
     Sets the log level to enable console output of network requests to your API.
     
     - parameter level: Level of logging, defaults to None. Debug will log all of the request and response data. Error will only log if there was an error using the lib.
     */
     
    public class func setLogLevel(level: LogLevel) {
        
        Logger.logLevel = level
        
    }
    
}

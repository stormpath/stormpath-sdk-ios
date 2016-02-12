//
//  Stormpath.swift
//  Stormpath
//
//  Created by Adis on 16/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import Foundation

public typealias CompletionBlockWithDictionary = ((NSDictionary?, NSError?) -> Void)
public typealias CompletionBlockWithSuccess     = ((Bool, NSError?) -> Void)
public typealias CompletionBlockWithError      = ((NSError?) -> Void)

public final class Stormpath: NSObject {
    public static var sharedSession = Stormpath(withIdentifier: "default")
    public var configuration = StormpathConfiguration.defaultConfiguration
    var apiService: APIService!
    var keychain: KeychainService!
    
    public init(withIdentifier identifier: String) {
        super.init()
        apiService = APIService(withStormpath: self)
        keychain = KeychainService(withIdentifier: identifier)
    }
    
    // MARK: User registration
    
    /**
     This method registers a user from the data provided.
    
     - parameter userDictionary: User data in the form of a dictionary. Check the docs for more info: http://docs.stormpath.com/rest/product-guide/#create-an-account
     - parameter completionHandler: The completion block to be invoked after the API request is finished. It returns a dictionary with user data,
        or an error if one occured.
     */
    
    public func register(userData: RegistrationModel, completionHandler: CompletionBlockWithDictionary) {
        
        apiService.register(userData, completionHandler: completionHandler)
        
    }
    
    // MARK: User login
    
    /**
    Logs in a user and assumes that the login path is behind the /login relative path. This method also stores the user session tokens for later use.
    
    - parameter username: User username.
    - parameter password: User password.
    - parameter completionHandler: The completion block to be invoked after the API request is finished. If the method fails, the error will be passed in the completion.
    */
    
    public func login(username: String, password: String, completionHandler: CompletionBlockWithSuccess) {
        
        apiService.login(username, password: password, completionHandler: completionHandler)
        
    }
    
    /**
     Fetches the user data, and returns it in the form of a dictionary.
     
     - parameter completionHandler: Completion block invoked
     */
    
    public func me(completionHandler: CompletionBlockWithDictionary) {
        
        apiService.me(completionHandler)
        
    }
    
    // MARK: User logout
    
    /**
    Logs out the user and clears the sessions tokens.
    
    - parameter completionHandler: The completion block to be invoked after the API request is finished. If the method fails, the error will be passed in the completion.
    */

    
    public func logout(completionHandler: CompletionBlockWithError) {
        
        apiService.logout(completionHandler)
        
    }
    
    // MARK: User password reset
    
    /**
    Generates a user password reset token and sends an email to the user, if such email exists.
    
    - parameter email: User email. Usually from an input.
    - parameter completionHandler: The completion block to be invoked after the API request is finished. If there were errors, they will be passed in the completion block.
    */
    
    public func resetPassword(email: String, completionHandler: CompletionBlockWithError) {
        
        apiService.resetPassword(email, completionHandler: completionHandler)
        
    }
    
    // MARK: Token management
    
    /**
    Provides the last access token fetched by either login or refreshAccessToken functions. The validity of the token is not verified upon fetching!
    
    - returns: Access token for your API calls.
    */
    
    internal(set) public var accessToken: String? {
        get {
            return keychain.accessToken
        }
        set {
            keychain.accessToken = newValue
        }
    }
    
    internal(set) public var refreshToken: String? {
        get {
            return keychain.refreshToken
        }
        set {
            keychain.refreshToken = newValue
        }
    }
    
    /**
     Refreshes the access token and stores it to be available via accessToken var. Call this function if your token expires.
     
     - parameter completionHandler: Block invoked on function completion. It will have either a new access token passed as a string, or an error if one occured.
     */
    
    public func refreshAccessToken(completionHandler: CompletionBlockWithSuccess) {
        
        apiService.refreshAccessToken(completionHandler)
        
    }
    
    /**
     Sets the log level to enable console output of network requests to your API.
     
     - parameter level: Level of logging, defaults to None.
        * .None - no output.
        * .Debug - will display which API calls are being used and their responses.
        * .Verbose - same as .Debug, but will output the headers and bodies of requests.
        * .Error - will output errors only.
     */
     
    public class func setLogLevel(level: LogLevel) {
        
        Logger.logLevel = level
        
    }
    
}

//
//  Stormpath.swift
//  Stormpath
//
//  Created by Adis on 16/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import Foundation

/// Callback for Stormpath API responses that respond with a success/fail.
public typealias StormpathSuccessCallback       = (Bool, NSError?) -> Void

/// Callback for Stormpath API responses that respond with a user object.
public typealias StormpathUserCallback          = (User?, NSError?) -> Void

/**
 Stormpath represents the state of the application's connection to the Stormpath 
 Framework server. It allows you to connect to the Stormpath Framework 
 Integration API, register, login, and stores the current user's access and 
 refresh tokens securely. All callbacks to the application are handled on the 
 main thread.
 */
public final class Stormpath: NSObject {
    /// Singleton representing the primary Stormpath instance using the default configuration.
    public static let sharedSession = Stormpath(withIdentifier: "default")
    
    /// Configuration parameter for the Stormpath object. Can be changed.
    public var configuration = StormpathConfiguration.defaultConfiguration
    
    /// Reference to the API Service.
    var apiService: APIService!
    
    /// Reference to the Keychain Service.
    var keychain: KeychainService!
    
    /**
     Initializes the Stormpath object with a default configuration. The 
     identifier is used to namespace the current state of the object, so that on 
     future loads we can find the saved credentials from the right location. The 
     default identifier is "default".
     */
    
    public init(withIdentifier identifier: String) {
        super.init()
        apiService = APIService(withStormpath: self)
        keychain = KeychainService(withIdentifier: identifier)
    }
    
    // MARK: User registration
    
    /**
     This method registers a user from the data provided.
     
     - parameters:
       - userData: A Registration Model object with the user data you want to 
         register.
       - completionHandler: The completion block to be invoked after the API 
         request is finished. It returns a user object.
    */
    
    public func register(userData: RegistrationModel, completionHandler: StormpathUserCallback) {
        
        apiService.register(userData, completionHandler: completionHandler)
        
    }
    
    // MARK: User login
    
    /**
     Logs in a user and assumes that the login path is behind the /login 
     relative path. This method also stores the user session tokens for later 
     use.
     
     - parameters:
       - username: User username.
       - password: User password.
       - completionHandler: The completion block to be invoked after the API 
         request is finished. If the method fails, the error will be passed in 
         the completion.
    */
    
    public func login(username: String, password: String, completionHandler: StormpathSuccessCallback) {
        
        apiService.login(username, password: password, completionHandler: completionHandler)
        
    }
    
    /**
     Fetches the user data, and returns it in the form of a dictionary.
     
     - parameters:
       - completionHandler: Completion block invoked
     */
    
    public func me(completionHandler: StormpathUserCallback) {
        
        apiService.me(completionHandler)
        
    }
    
    // MARK: User logout
    
    /**
     Logs out the user and clears the sessions tokens.
     
     - parameters:
       - completionHandler: The completion block to be invoked after the API 
         request is finished. If the method fails, the error will be passed in 
         the completion.
    */

    
    public func logout(completionHandler: StormpathSuccessCallback) {
        
        apiService.logout(completionHandler)
        
    }
    
    // MARK: User password reset
    
    /**
     Generates a user password reset token and sends an email to the user, if 
     such email exists.
     
     - parameters:
       - email: User email. Usually from an input.
       - completionHandler: The completion block to be invoked after the API 
         request is finished. If there were errors, they will be passed in the 
         completion block.
    */
    
    public func resetPassword(email: String, completionHandler: StormpathSuccessCallback) {
        
        apiService.resetPassword(email, completionHandler: completionHandler)
        
    }
    
    // MARK: Token management
    
    /**
     Provides the last access token fetched by either login or 
     refreshAccessToken functions. The validity of the token is not verified 
     upon fetching!
     
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
    
    /// Refresh token for the current user. 
    internal(set) public var refreshToken: String? {
        get {
            return keychain.refreshToken
        }
        set {
            keychain.refreshToken = newValue
        }
    }
    
    /**
     Refreshes the access token and stores it to be available via accessToken 
     var. Call this function if your token expires.
     
     - parameters:
       - completionHandler: Block invoked on function completion. It will have 
         either a new access token passed as a string, or an error if one 
         occurred.
     */
    
    public func refreshAccessToken(completionHandler: StormpathSuccessCallback) {
        
        apiService.refreshAccessToken(completionHandler)
        
    }
    
}
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

/// Callback for Stormpath API responses that respond with an account object.
public typealias StormpathAccountCallback          = (Account?, NSError?) -> Void

/**
 Stormpath represents the state of the application's connection to the Stormpath 
 Framework server. It allows you to connect to the Stormpath Framework 
 Integration API, register, login, and stores the current account's access and
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
    
    // MARK: Account registration
    
    /**
     This method registers an account from the data provided.
     
     - parameters:
       - account: A Registration Model object with the account data you want to
         register.
       - completionHandler: The completion block to be invoked after the API 
         request is finished. It returns an account object.
    */
    
    public func register(account: RegistrationModel, completionHandler: StormpathAccountCallback?) {
        
        apiService.register(newAccount: account, completionHandler: completionHandler)
        
    }
    
    // MARK: Account login
    
    /**
     Logs in an account and assumes that the login path is behind the /login
     relative path. This method also stores the account session tokens for later
     use.
     
     - parameters:
       - username: Account's email or username.
       - password: Account password.
       - completionHandler: The completion block to be invoked after the API 
         request is finished. If the method fails, the error will be passed in 
         the completion.
    */
    
    public func login(username: String, password: String, completionHandler: StormpathSuccessCallback?) {
        
        apiService.login(username, password: password, completionHandler: completionHandler)
        
    }
    
    /**
     Fetches the account data, and returns it in the form of a dictionary.
     
     - parameters:
       - completionHandler: Completion block invoked
     */
    
    public func me(completionHandler: StormpathAccountCallback?) {
        
        apiService.me(completionHandler)
        
    }
    
    // MARK: Account logout
    
    /**
     Logs out the account and clears the sessions tokens.
    */

    
    public func logout() {
        
        apiService.logout()
        
    }
    
    // MARK: Account password reset
    
    /**
     Generates an account password reset token and sends an email to the user,
     if such email exists.
    - parameters:
       - email: Account email. Usually from an input.
       - completionHandler: The completion block to be invoked after the API
         request is finished. This will always succeed if the API call is 
         successful.
    */
    
    public func resetPassword(email: String, completionHandler: StormpathSuccessCallback?) {
        
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
    
    /// Refresh token for the current account. 
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
    
    public func refreshAccessToken(completionHandler: StormpathSuccessCallback?) {
        
        apiService.refreshAccessToken(completionHandler)
        
    }
    
}
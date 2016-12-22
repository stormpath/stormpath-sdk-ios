//
//  Stormpath.swift
//  Stormpath
//
//  Created by Adis on 16/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import Foundation

/// Callback for Stormpath API responses that respond with a success/fail.
public typealias StormpathSuccessCallback = (Bool, NSError?) -> Void

/// Callback for Stormpath API responses that respond with an account object.
public typealias StormpathAccountCallback = (Account?, NSError?) -> Void

/**
 Stormpath represents the state of the application's connection to the Stormpath 
 Client API. It allows you to connect to the Stormpath Client API, 
 register, login, and stores the current account's access and
 refresh tokens securely. All callbacks to the application are handled on the 
 main thread.
 */
@objc(SPHStormpath)
public final class Stormpath: NSObject {
    /// Singleton representing the primary Stormpath instance using the default configuration.
    public static let sharedSession = Stormpath(identifier: "default")
    
    /// Configuration parameter for the Stormpath object. Can be changed.
    public var configuration = StormpathConfiguration.defaultConfiguration
    
    /// Reference to the API Service.
    var apiService: APIService!
    
    /// Reference to the Social Login Service.
    var socialLoginService: SocialLoginService!
    
    /// Reference to the Keychain Service.
    var keychain: KeychainService!
    
    /// API Client
    var apiClient: APIClient!
    
    /**
     Initializes the Stormpath object with a default configuration. The 
     identifier is used to namespace the current state of the object, so that on 
     future loads we can find the saved credentials from the right location. The 
     default identifier is "default".
     */
    public init(identifier: String) {
        super.init()
        apiService = APIService(withStormpath: self)
        keychain = KeychainService(withIdentifier: identifier)
        socialLoginService = SocialLoginService(withStormpath: self)
        apiClient = APIClient(stormpath: self)
    }
    
    /**
     This method registers an account from the data provided.
     
     - parameters:
       - account: A RegistrationForm object with the account data you want to
         register.
       - callback: The completion block to be invoked after the API
         request is finished. It returns an account object.
    */
    public func register(account: RegistrationForm, callback: StormpathAccountCallback? = nil) {
        apiService.register(newAccount: account, callback: callback)
    }
    
    /**
     Logs in an account. This method also stores the account access tokens for later
     use.
     
     - parameters:
       - username: Account's email or username.
       - password: Account password.
       - callback: The completion block to be invoked after the API
         request is finished. If the method fails, the error will be passed in 
         the completion.
    */
    public func login(username: String, password: String, callback: StormpathSuccessCallback? = nil) {
        apiService.login(username: username, password: password, callback: callback)
    }
    
    /**
     Begins a login flow with a social provider, presenting or opening up Safari 
     (iOS8) to handle login. This WILL NOT call back if the user clicks "cancel" 
     on the login screen, as they never began the login process in the first 
     place. 
     
     - parameters:
       - socialProvider: the provider (Facebook, Google, etc) from which you 
         have an access token
       - callback: Callback on success or failure
     */
    public func login(provider: Provider, callback: StormpathSuccessCallback? = nil) {
        socialLoginService.login(provider: provider, callback: callback)
    }
    
    
    /**
     Logs in an account if you have an access token from a social provider.
     
     - parameters:
       - socialProvider: the provider (Facebook, Google, etc) from which you
         have an access token
       - accessToken: String containing the access token
       - callback: A block of code that is called back on success or
         failure.
     */
    public func login(provider: Provider, accessToken: String, callback: StormpathSuccessCallback? = nil) {
        apiService.login(socialProvider: provider, accessToken: accessToken, callback: callback)
    }
    
    /**
    Logs in an account if you have an authorization code from a social provider.
    
    - parameters:
      - socialProvider: the provider (Facebook, Google, etc) from which you have 
        an access token
      - authorizationCode: String containing the authorization code
      - callback: A block of code that is called back on success or 
        failure.
     */
    // Making this internal for now, since we don't support auth codes for FB / 
    // Google
    func login(provider: Provider, authorizationCode: String, callback: StormpathSuccessCallback? = nil) {
        apiService.login(socialProvider: provider, authorizationCode: authorizationCode, callback: callback)
    }
    
    /**
     Fetches the account data, and returns it in the form of a dictionary.
     
     - parameters:
       - callback: Completion block invoked
     */
    public func me(callback: StormpathAccountCallback? = nil) {
        apiService.me(callback)
    }
    
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
       - callback: The completion block to be invoked after the API
         request is finished. This will always succeed if there are no network problems.
    */
    public func resetPassword(email: String, callback: StormpathSuccessCallback? = nil) {
        apiService.resetPassword(email, callback: callback)
    }
    
    /// Deep link handler (iOS9)
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return socialLoginService.handleCallbackURL(url)
    }
    
    
    /// Deep link handler (<iOS9)
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.application(application, open: url, options: [UIApplicationOpenURLOptionsKey: Any]())
    }
    
    /**
     Provides the last access token fetched by either login or 
     refreshAccessToken functions.
     
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
       - callback: Block invoked on function completion. It will have 
         either a new access token passed as a string, or an error if one 
         occurred.
     */
    
    public func refreshAccessToken(callback: StormpathSuccessCallback? = nil) {
        apiService.refreshAccessToken(callback)
    }
}

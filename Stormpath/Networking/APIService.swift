//
//  APIService.swift
//  Stormpath
//
//  Created by Adis on 18/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

internal final class APIService: NSObject {
    weak var stormpath: Stormpath!
    
    init(withStormpath stormpath: Stormpath) {
        self.stormpath = stormpath
    }
    
    // MARK: Registration
    
    internal func register(newUser: RegistrationModel, completionHandler: CompletionBlockWithDictionary) {
        
        let registerURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.registerEndpoint)
        
        let requestManager = RegistrationAPIRequestManager(withURL: registerURL, newUser: newUser, callback: completionHandler)
        requestManager.begin()
        
    }
    
    // MARK: Login
    
    internal func login(username: String, password: String, completionHandler: CompletionBlockWithString) {
        
        let oauthURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.oauthEndpoint)
        let requestManager = OAuthAPIRequestManager(withURL: oauthURL, username: username, password: password, callback: completionHandler)
        requestManager.begin()
        
    }
    
    // MARK: Access token refresh
    
    internal func refreshAccessToken(completionHandler: CompletionBlockWithString) {
        let oauthURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.oauthEndpoint)
        
        guard let refreshToken = KeychainService.refreshToken else {
            let error = NSError(domain: oauthURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(nil, error)
            })
            return
        }
        
        let requestManager = OAuthAPIRequestManager(withURL: oauthURL, refreshToken: refreshToken, callback: completionHandler)
        requestManager.begin()
        
    }
    
    // MARK: User data
    
    internal func me(completionHandler: CompletionBlockWithDictionary) {
        let meURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.meEndpoint)
        
        guard let accessToken = KeychainService.accessToken else {
            let error = NSError(domain: meURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(nil, error)
            })
            return
        }
        
        let requestManager = MeAPIRequestManager(withURL: meURL, accessToken: accessToken, callback: completionHandler)
        requestManager.begin()
    }
    
    // MARK: Logout
    
    internal func logout(completionHandler: CompletionBlockWithError) {
        
        let logoutURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.logoutEndpoint)
        let request = NSMutableURLRequest(URL: logoutURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
        
        Logger.logRequest(request)
        
        // Regardless of how the API calls goes, we can logout the user locally
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil
        
        // TODO: Hit the API to delete the access token, because this literally does nothing right now. 
        
    }
    
    // MARK: Forgot password
    
    internal func resetPassword(email: String, completionHandler: CompletionBlockWithError) {
     
        let resetPasswordURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.forgotPasswordEndpoint)
        let requestManager = ResetPasswordAPIRequestManager(withURL: resetPasswordURL, email: email, callback: completionHandler)
        requestManager.begin()
    }
}

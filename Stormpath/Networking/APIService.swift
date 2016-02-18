//
//  APIService.swift
//  Stormpath
//
//  Created by Adis on 18/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import Foundation

final class APIService: NSObject {
    weak var stormpath: Stormpath!
    
    init(withStormpath stormpath: Stormpath) {
        self.stormpath = stormpath
    }
    
    // MARK: Registration
    
    func register(newAccount account: RegistrationModel, completionHandler: StormpathAccountCallback?) {
        let registerURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.registerEndpoint)
        
        let requestManager = RegistrationAPIRequestManager(withURL: registerURL, newAccount: account) { (account, error) -> Void in
            completionHandler?(account, error)
        }
        requestManager.begin()
        
    }
    
    // MARK: Login
    
    func login(username: String, password: String, completionHandler: StormpathSuccessCallback?) {
        
        let oauthURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.oauthEndpoint)
        let requestManager = OAuthAPIRequestManager(withURL: oauthURL, username: username, password: password) { (accessToken, refreshToken, error) -> Void in
            guard let accessToken = accessToken where error == nil else {
                completionHandler?(false, error)
                return
            }
            self.stormpath.keychain.accessToken = accessToken
            
            //TODO: double check refresh token behavior on refreshing
            if refreshToken != nil {
                self.stormpath.keychain.refreshToken = refreshToken
            }
            completionHandler?(true, nil)
        }
        requestManager.begin()
        
    }
    
    // MARK: Access token refresh
    
    func refreshAccessToken(completionHandler: StormpathSuccessCallback?) {
        let oauthURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.oauthEndpoint)
        
        guard let refreshToken = stormpath.refreshToken else {
            let error = NSError(domain: oauthURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler?(false, error)
            })
            return
        }
        
        let requestManager = OAuthAPIRequestManager(withURL: oauthURL, refreshToken: refreshToken) { (accessToken, refreshToken, error) -> Void in
            guard let accessToken = accessToken where error == nil else {
                completionHandler?(false, error)
                return
            }
            self.stormpath.accessToken = accessToken
            self.stormpath.refreshToken = refreshToken
            completionHandler?(true, nil)
        }
        requestManager.begin()
        
    }
    
    // MARK: Account data
    
    func me(completionHandler: StormpathAccountCallback?) {
        let meURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.meEndpoint)
        
        guard let accessToken = stormpath.accessToken else {
            let error = NSError(domain: meURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler?(nil, error)
            })
            return
        }
        let requestManager = MeAPIRequestManager(withURL: meURL, accessToken: accessToken) { (account, error) -> Void in
            if error?.code == 401 {
                //Refresh access token & retry
                self.stormpath.refreshAccessToken({ (success, error) -> Void in
                    guard error == nil else {
                        completionHandler?(nil, error)
                        return
                    }
                    self.stormpath.me(completionHandler)
                })
            } else {
                completionHandler?(account, error)
            }
        }
        requestManager.begin()
    }
    
    // MARK: Logout
    
    func logout() {
        
        let logoutURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.logoutEndpoint)
        let request = NSMutableURLRequest(URL: logoutURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
        
        Logger.logRequest(request)
        
        // Regardless of how the API calls goes, we can logout the user locally
        stormpath.accessToken = nil
        stormpath.refreshToken = nil
        
        // TODO: Hit the API to delete the access token, because this literally does nothing right now. 
        
    }
    
    // MARK: Forgot password
    
    func resetPassword(email: String, completionHandler: StormpathSuccessCallback?) {
        let resetPasswordURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.forgotPasswordEndpoint)
        let requestManager = ResetPasswordAPIRequestManager(withURL: resetPasswordURL, email: email, callback: { (error) -> Void in
                completionHandler?(error == nil, error)
        })
        requestManager.begin()
    }
}

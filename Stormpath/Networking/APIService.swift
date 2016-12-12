//
//  APIService.swift
//  Stormpath
//
//  Created by Adis on 18/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import Foundation

typealias AccessTokenCallback = (_ accessToken: String?, _ refreshToken: String?, _ error: NSError?) -> Void

final class APIService: NSObject {
    weak var stormpath: Stormpath!
    
    init(withStormpath stormpath: Stormpath) {
        self.stormpath = stormpath
    }
    
    // MARK: Registration
    
    func register(newAccount account: RegistrationModel, completionHandler: StormpathAccountCallback?) {
        let registerURL = stormpath.configuration.APIURL.appendingPathComponent(stormpath.configuration.registerEndpoint)
        
        let requestManager = RegistrationAPIRequestManager(withURL: registerURL, newAccount: account) { (account, error) -> Void in
            completionHandler?(account, error)
        }
        requestManager.begin()
        
    }
    
    // MARK: Login
    
    func login(username: String, password: String, completionHandler: StormpathSuccessCallback?) {
        let oauthURL = stormpath.configuration.APIURL.appendingPathComponent(stormpath.configuration.oauthEndpoint)
        
        var apiRequest = APIRequest(method: .post, url: oauthURL)
        apiRequest.contentType = .urlEncoded
        apiRequest.body = [ "grant_type": "password",
                            "username": username,
                            "password": password]
        
        apiRequest.send { (response, error) in
            let accessToken = response?.json?["access_token"] as? String
            let refreshToken = response?.json?["refresh_token"] as? String
            
            self.loginCompletionHandler(accessToken, refreshToken: refreshToken, error: error, completionHandler: completionHandler)
        }
    }
    
    func login(socialProvider provider: StormpathSocialProvider, accessToken: String, completionHandler: StormpathSuccessCallback?) {
        let socialLoginURL = stormpath.configuration.APIURL.appendingPathComponent(stormpath.configuration.oauthEndpoint)
        
        var apiRequest = APIRequest(method: .post, url: socialLoginURL)
        apiRequest.contentType = .urlEncoded
        apiRequest.body = [ "grant_type": "stormpath_social",
                            "providerId": provider.stringValue(),
                            "accessToken": accessToken]
        
        apiRequest.send { (response, error) in
            let accessToken = response?.json?["access_token"] as? String
            let refreshToken = response?.json?["refresh_token"] as? String
            
            self.loginCompletionHandler(accessToken, refreshToken: refreshToken, error: error, completionHandler: completionHandler)
        }
    }
    
    func login(socialProvider provider: StormpathSocialProvider, authorizationCode: String, completionHandler: StormpathSuccessCallback?) {
        let socialLoginURL = stormpath.configuration.APIURL.appendingPathComponent(stormpath.configuration.oauthEndpoint)
        
        var apiRequest = APIRequest(method: .post, url: socialLoginURL)
        apiRequest.contentType = .urlEncoded
        apiRequest.body = [ "grant_type": "stormpath_social",
                            "providerId": provider.stringValue(),
                            "code": authorizationCode]
        
        apiRequest.send { (response, error) in
            let accessToken = response?.json?["access_token"] as? String
            let refreshToken = response?.json?["refresh_token"] as? String
            
            self.loginCompletionHandler(accessToken, refreshToken: refreshToken, error: error, completionHandler: completionHandler)
        }
    }
    
    func loginCompletionHandler(_ accessToken: String?, refreshToken: String?, error: NSError?, completionHandler: StormpathSuccessCallback?) {
        guard let accessToken = accessToken, error == nil else {
            completionHandler?(false, error)
            return
        }
        stormpath.accessToken = accessToken
        
        if refreshToken != nil {
            stormpath.refreshToken = refreshToken
        } else {
            stormpath.refreshToken = nil
        }
        completionHandler?(true, nil)
    }
    
    // MARK: Access token refresh
    
    func refreshAccessToken(_ completionHandler: StormpathSuccessCallback?) {
        let oauthURL = stormpath.configuration.APIURL.appendingPathComponent(stormpath.configuration.oauthEndpoint)
        
        guard let refreshToken = stormpath.refreshToken else {
            let error = NSError(domain: oauthURL.absoluteString, code: 400, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            DispatchQueue.main.async(execute: { () -> Void in
                completionHandler?(false, error)
            })
            return
        }
        
        var apiRequest = APIRequest(method: .post, url: oauthURL)
        apiRequest.contentType = .urlEncoded
        apiRequest.body = ["grant_type": "refresh_token",
                           "refresh_token": refreshToken]
        
        apiRequest.send { (response, error) in
            let accessToken = response?.json?["access_token"] as? String
            let refreshToken = response?.json?["refresh_token"] as? String
            
            self.loginCompletionHandler(accessToken, refreshToken: refreshToken, error: error, completionHandler: completionHandler)
        }
    }
    
    // MARK: Account data
    
    func me(_ completionHandler: StormpathAccountCallback?) {
        let meURL = stormpath.configuration.APIURL.appendingPathComponent(stormpath.configuration.meEndpoint)
        
        guard let accessToken = stormpath.accessToken else {
            let error = NSError(domain: meURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            DispatchQueue.main.async(execute: { () -> Void in
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
                    let retryRequestManager = MeAPIRequestManager(withURL: meURL, accessToken: accessToken, callback: { (account, error) -> Void in
                        completionHandler?(account, error)
                    })
                    retryRequestManager.begin()
                })
            } else {
                completionHandler?(account, error)
            }
        }
        requestManager.begin()
    }
    
    // MARK: Logout
    
    func logout() {
        
        let logoutURL = stormpath.configuration.APIURL.appendingPathComponent(stormpath.configuration.logoutEndpoint)
        var request = URLRequest(url: logoutURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        Logger.logRequest(request)
        
        // Regardless of how the API calls goes, we can logout the user locally
        stormpath.accessToken = nil
        stormpath.refreshToken = nil
        
        // The API response is not defined, so we won't call the API for now.
    }
    
    // MARK: Forgot password
    
    func resetPassword(_ email: String, completionHandler: StormpathSuccessCallback?) {
        let resetPasswordURL = stormpath.configuration.APIURL.appendingPathComponent(stormpath.configuration.forgotPasswordEndpoint)
        let requestManager = ResetPasswordAPIRequestManager(withURL: resetPasswordURL, email: email, callback: { (error) -> Void in
                completionHandler?(error == nil, error)
        })
        requestManager.begin()
    }
}

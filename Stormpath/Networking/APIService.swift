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
    
    func register(newAccount account: RegistrationForm, callback: StormpathAccountCallback?) {
        let registerURL = stormpath.configuration.APIURL.appendingPathComponent(Endpoints.register.rawValue)
        
        var apiRequest = APIRequest(method: .post, url: registerURL)
        apiRequest.body = account.asDictionary
        
        apiRequest.send { (response, error) in
            if let data = response?.body,
                let account = Account(fromJSON: data) {
                callback?(account, nil)
            } else {
                callback?(nil, error ?? StormpathError.APIResponseError)
            }
        }
    }
    
    // MARK: Login
    
    func login(username: String, password: String, callback: StormpathSuccessCallback?) {
        let oauthURL = stormpath.configuration.APIURL.appendingPathComponent(Endpoints.oauthToken.rawValue)
        
        var apiRequest = APIRequest(method: .post, url: oauthURL)
        apiRequest.contentType = .urlEncoded
        apiRequest.body = [ "grant_type": "password",
                            "username": username,
                            "password": password]
        
        login(request: apiRequest, callback: callback)
    }
    
    func login(socialProvider provider: Provider, accessToken: String, callback: StormpathSuccessCallback?) {
        let socialLoginURL = stormpath.configuration.APIURL.appendingPathComponent(Endpoints.oauthToken.rawValue)
        
        var apiRequest = APIRequest(method: .post, url: socialLoginURL)
        apiRequest.contentType = .urlEncoded
        apiRequest.body = [ "grant_type": "stormpath_social",
                            "providerId": provider.asString,
                            "accessToken": accessToken]
        
        login(request: apiRequest, callback: callback)
    }
    
    func login(socialProvider provider: Provider, authorizationCode: String, callback: StormpathSuccessCallback?) {
        let socialLoginURL = stormpath.configuration.APIURL.appendingPathComponent(Endpoints.oauthToken.rawValue)
        
        var apiRequest = APIRequest(method: .post, url: socialLoginURL)
        apiRequest.contentType = .urlEncoded
        apiRequest.body = [ "grant_type": "stormpath_social",
                            "providerId": provider.asString,
                            "code": authorizationCode]
        
        login(request: apiRequest, callback: callback)
    }
    
    func login(request: APIRequest, callback: StormpathSuccessCallback?) {
        request.send { (response, error) in
            let accessToken = response?.json["access_token"].string
            let refreshToken = response?.json["refresh_token"].string
            
            if let accessToken = accessToken, error == nil {
                self.stormpath.accessToken = accessToken
                self.stormpath.refreshToken = refreshToken
                
                callback?(true, nil)
            }
            else {
                callback?(false, error)
                return
            }
        }
    }
    
    // MARK: Access token refresh
    
    func refreshAccessToken(_ callback: StormpathSuccessCallback?) {
        let oauthURL = stormpath.configuration.APIURL.appendingPathComponent(Endpoints.oauthToken.rawValue)
        
        guard let refreshToken = stormpath.refreshToken else {
            let error = NSError(domain: oauthURL.absoluteString, code: 400, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            DispatchQueue.main.async(execute: { () -> Void in
                callback?(false, error)
            })
            return
        }
        
        var apiRequest = APIRequest(method: .post, url: oauthURL)
        apiRequest.contentType = .urlEncoded
        apiRequest.body = ["grant_type": "refresh_token",
                           "refresh_token": refreshToken]
        
        login(request: apiRequest, callback: callback)
    }
    
    // MARK: Account data
    
    func me(_ callback: StormpathAccountCallback?) {
        let meURL = stormpath.configuration.APIURL.appendingPathComponent(Endpoints.me.rawValue)
        
        guard stormpath.accessToken != nil else {
            let error = NSError(domain: meURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            DispatchQueue.main.async(execute: { () -> Void in
                callback?(nil, error)
            })
            return
        }
        
        let request = APIRequest(method: .get, url: meURL)
        stormpath.apiClient.execute(request: request) { (response, error) in
            if let data = response?.body,
               let account = Account(fromJSON: data) {
                callback?(account, nil)
            } else {
                callback?(nil, error ?? StormpathError.APIResponseError)
            }
        }
    }
    
    // MARK: Logout
    
    func logout() {
        let logoutURL = stormpath.configuration.APIURL.appendingPathComponent(Endpoints.oauthRevoke.rawValue)
        
        var request = APIRequest(method: .post, url: logoutURL)
        request.contentType = .urlEncoded
        request.body = ["token": stormpath.refreshToken as Any]
        request.send()
        
        // Regardless of how the API calls goes, we can logout the user locally
        stormpath.accessToken = nil
        stormpath.refreshToken = nil
    }
    
    // MARK: Forgot password
    
    func resetPassword(_ email: String, callback: StormpathSuccessCallback?) {
        let resetPasswordURL = stormpath.configuration.APIURL.appendingPathComponent(Endpoints.forgot.rawValue)
        
        var request = APIRequest(method: .post, url: resetPasswordURL)
        request.body = ["login": email]
        request.send { (response, error) in
            if response?.status == 200 {
                callback?(true, nil)
            } else {
                callback?(false, StormpathError.APIResponseError)
            }
        }
    }
    
    typealias LoginModelCallback = (LoginModel?, NSError?) -> Void
    private var _loginModel: LoginModel?
    
    func loginModel(callback: LoginModelCallback? = nil) {
        guard _loginModel == nil else {
            DispatchQueue.main.async {
                callback?(self._loginModel, nil)
            }
            return
        }
        let request = APIRequest(method: .get, url: stormpath.configuration.APIURL.appendingPathComponent(Endpoints.login.rawValue))
        request.send { (response, error) in
            if let response = response,
                let loginModel = LoginModel(json: response.json) {
                self._loginModel = loginModel
                callback?(loginModel, nil)
            } else {
                callback?(nil, error ?? StormpathError.APIResponseError)
            }
        }
    }
}

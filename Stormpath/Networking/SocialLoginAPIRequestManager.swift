//
//  SocialLoginAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/3/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class SocialLoginAPIRequestManager: APIRequestManager {
    var socialProvider: StormpathSocialProvider
    var callback: AccessTokenCallback
    var postDictionary: [String: Any]
    
    init(withURL url: URL, accessToken: String, socialProvider: StormpathSocialProvider, callback: @escaping AccessTokenCallback) {
        self.socialProvider = socialProvider
        self.callback = callback
        postDictionary = ["providerData": ["providerId": socialProvider.stringValue(), "accessToken": accessToken]]
        
        super.init(withURL: url)
    }
    
    init(withURL url: URL, authorizationCode: String, socialProvider: StormpathSocialProvider, callback: @escaping AccessTokenCallback) {
        self.socialProvider = socialProvider
        self.callback = callback
        postDictionary = ["providerData": ["providerId": socialProvider.stringValue(), "code": authorizationCode]]
        
        super.init(withURL: url)
    }
    
    override func prepareForRequest() {
        request.httpBody = try? JSONSerialization.data(withJSONObject: postDictionary, options: [])
        request.httpMethod = "POST"
    }
    
    override func requestDidFinish(_ data: Data, response: HTTPURLResponse) {
        // Grab access token from cookies
        // Callback
        
        let accessTokenRegex = "(?<=access_token=)[^;]*"
        let refreshTokenRegex = "(?<=refresh_token=)[^;]*"
        
        guard let setCookieHeaders = response.allHeaderFields["Set-Cookie"] as? String, let accessTokenRange = setCookieHeaders.range(of: accessTokenRegex, options: .regularExpression) else {
            performCallback(StormpathError.APIResponseError)
            return
        }
        
        let accessToken = setCookieHeaders.substring(with: accessTokenRange)
        
        var refreshToken: String?
        
        if let refreshTokenRange = setCookieHeaders.range(of: refreshTokenRegex, options: .regularExpression) {
            refreshToken = setCookieHeaders.substring(with: refreshTokenRange)
        }
        
        performCallback(accessToken, refreshToken: refreshToken, error: nil)
    }
    
    override func performCallback(_ error: NSError?) {
        performCallback(nil, refreshToken: nil, error: error)
    }
    
    func performCallback(_ accessToken: String?, refreshToken: String?, error: NSError?) {
        DispatchQueue.main.async {
            self.callback(accessToken, refreshToken, error)
        }
    }
}

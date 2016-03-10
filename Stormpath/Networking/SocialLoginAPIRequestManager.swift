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
    var postDictionary: [String: AnyObject]
    
    init(withURL url: NSURL, accessToken: String, socialProvider: StormpathSocialProvider, callback: AccessTokenCallback) {
        self.socialProvider = socialProvider
        self.callback = callback
        postDictionary = ["providerData": ["providerId": socialProvider.stringValue(), "accessToken": accessToken]]
        
        super.init(withURL: url)
    }
    
    init(withURL url: NSURL, authorizationCode: String, socialProvider: StormpathSocialProvider, callback: AccessTokenCallback) {
        self.socialProvider = socialProvider
        self.callback = callback
        postDictionary = ["providerData": ["providerId": socialProvider.stringValue(), "code": authorizationCode]]
        
        super.init(withURL: url)
    }
    
    override func prepareForRequest() {
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(postDictionary, options: [])
        request.HTTPMethod = "POST"
    }
    
    override func requestDidFinish(data: NSData, response: NSHTTPURLResponse) {
        // Grab access token from cookies
        // Callback
        
        let accessTokenRegex = "(?<=access_token=)[^;]*"
        let refreshTokenRegex = "(?<=refresh_token=)[^;]*"
        
        guard let setCookieHeaders = response.allHeaderFields["Set-Cookie"] as? String, accessTokenRange = setCookieHeaders.rangeOfString(accessTokenRegex, options: .RegularExpressionSearch) else {
            performCallback(error: StormpathError.APIResponseError)
            return
        }
        
        let accessToken = setCookieHeaders.substringWithRange(accessTokenRange)
        
        var refreshToken: String?
        
        if let refreshTokenRange = setCookieHeaders.rangeOfString(refreshTokenRegex, options: .RegularExpressionSearch) {
            refreshToken = setCookieHeaders.substringWithRange(refreshTokenRange)
        }
        
        performCallback(accessToken, refreshToken: refreshToken, error: nil)
    }
    
    override func performCallback(error error: NSError?) {
        performCallback(nil, refreshToken: nil, error: error)
    }
    
    func performCallback(accessToken: String?, refreshToken: String?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.callback(accessToken: accessToken, refreshToken: refreshToken, error: error)
        }
    }
}
//
//  FacebookLoginProvider.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/7/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class FacebookLoginProvider: NSObject, LoginProvider {
    var urlSchemePrefix = "fb"
    var state = arc4random_uniform(10000000)
    
    func authenticationRequestURL(_ application: StormpathSocialProviderConfiguration) -> URL {
        let scopes = application.scopes ?? "email"
        
        // Auth_type is re-request since we need to ask for email scope again if 
        // people decline the email permission. If it gets annoying because
        // people keep asking for more scopes, we can change this.
        let queryString = "client_id=\(application.appId)&redirect_uri=\(application.urlScheme)://authorize&response_type=token&scope=\(scopes)&state=\(state)&auth_type=rerequest".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        return URL(string: "https://www.facebook.com/dialog/oauth?\(queryString)")!
    }
    
    func getResponseFromCallbackURL(_ url: URL, callback: @escaping LoginProviderCallback) {
        if(url.queryDictionary["error"] != nil) {
            // We are not even going to callback, because the user never started 
            // the login process in the first place. Error is always because
            // people cancelled the FB login according to https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow
            return
        }
        
        // Get the access token, and check that the state is the same
        guard let accessToken = url.fragmentDictionary["access_token"], url.fragmentDictionary["state"] == "\(state)" else {
            callback(nil, StormpathError.InternalSDKError)
            return
        }
        
        callback(LoginProviderResponse(data: accessToken, type: .accessToken), nil)
    }
}

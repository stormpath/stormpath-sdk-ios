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
    
    func authenticationRequestURL(application: StormpathSocialProviderConfiguration) -> NSURL {
        let scopes = application.scopes ?? "email"
        return NSURL(string: "https://www.facebook.com/dialog/oauth?client_id=\(application.appId)&redirect_uri=\(application.urlScheme)://authorize&response_type=token&scope=\(scopes)&state=\(state)")!
    }
    
    func getResponseFromCallbackURL(url: NSURL, callback: LoginProviderCallback) {
        //TODO: handle error conditions, verify state
        
        if let accessToken = url.fragmentDictionary["access_token"] {
            callback(LoginProviderResponse(data: accessToken, type: .AccessToken), nil)
        }
        else {
            callback(nil, StormpathError.InternalSDKError)
        }
    }
}

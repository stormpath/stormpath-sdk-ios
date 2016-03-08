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
    
    func authenticationRequestURL(scopes: [String], application: StormpathLoginProviderApplication) -> NSURL {
        // TODO: add scopes
        return NSURL(string: "https://www.facebook.com/dialog/oauth?client_id=\(application.appId)&redirect_uri=\(application.urlScheme)://authorize&response_type=token&scope=email")!
    }
    
    func getResponseFromCallbackURL(url: NSURL) throws -> LoginProviderResponse {
        //TODO: handle error conditions
        
        if let accessToken = url.fragmentDictionary["access_token"] {
            return LoginProviderResponse(data: accessToken, type: .AccessToken)
        }
        throw StormpathError.InternalSDKError
    }
    
}

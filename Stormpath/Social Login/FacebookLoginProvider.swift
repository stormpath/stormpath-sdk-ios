//
//  FacebookLoginProvider.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/7/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class FacebookLoginProvider: NSObject, LoginProvider {
    func authenticationRequestURL(scopes: [String], urlScheme: StormpathLoginProviderURLScheme) -> NSURL {
        // TODO: add scopes
        return NSURL(string: "https://www.facebook.com/dialog/oauth?client_id=\(urlScheme.appId)&redirect_uri=\(urlScheme.urlScheme)://authorize&response_type=token&scope=email")!
    }
    
    func getResponseFromCallbackURL(url: NSURL) throws -> LoginProviderResponse {
        //TODO: handle error conditions
        
        if let accessToken = url.fragmentDictionary["access_token"] {
            return LoginProviderResponse(data: accessToken, type: .AccessToken)
        }
        throw StormpathError.InternalSDKError
    }
    
}

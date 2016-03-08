//
//  GoogleLoginProvider.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/8/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class GoogleLoginProvider: NSObject, LoginProvider {
    var urlSchemePrefix = "com.googleusercontent.apps."
    
    func authenticationRequestURL(application: StormpathSocialProviderConfiguration) -> NSURL {
        let scopes = application.scopes ?? "email profile"
        return NSURL(string: "https://accounts.google.com/o/oauth2/auth?response_type=code&scope=\(scopes))&redirect_uri=\(application.urlScheme):/oauth2callback&client_id=\(application.appId)")!
    }
    
    func getResponseFromCallbackURL(url: NSURL) throws -> LoginProviderResponse {
        //TODO: handle error conditions
        
        if let authorizationCode = url.queryDictionary["code"] {
            return LoginProviderResponse(data: authorizationCode, type: .AuthorizationCode)
        }
        throw StormpathError.InternalSDKError
    }
}

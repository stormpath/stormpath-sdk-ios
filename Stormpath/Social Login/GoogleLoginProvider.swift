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
    
    func getResponseFromCallbackURL(url: NSURL) throws -> LoginProviderResponse {
        preconditionFailure() // TODO
    }
    
    func authenticationRequestURL(scopes: [String], application: StormpathLoginProviderApplication) -> NSURL {
        preconditionFailure() // TODO
    }
}

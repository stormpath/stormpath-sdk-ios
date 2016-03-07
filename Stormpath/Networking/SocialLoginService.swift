//
//  SocialLoginService.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/4/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation
import SafariServices

class SocialLoginService: NSObject {
    static let socialURLSchemePrefixes: [String: StormpathSocialProvider] =
        ["fb": .Facebook,
        "com.googleusercontent.apps.": .Google]
    private static let socialProviderHandlers: [StormpathSocialProvider: LoginProvider] = [.Facebook: FacebookLoginProvider()] // TODO: These two are the same thing, refactor this out
    
    weak var stormpath: Stormpath!
    var queuedCompletionHandler: StormpathSuccessCallback?
    
    init(withStormpath stormpath: Stormpath) {
        super.init()
        self.stormpath = stormpath
    }
    
    func beginLoginFlow(socialProvider: StormpathSocialProvider, scopes: [String], completionHandler: StormpathSuccessCallback?) {
        guard socialProvider == .Facebook else {
            preconditionFailure("Other social providers not supported yet")
        }
        
        guard let urlScheme = stormpath.configuration.socialProviderURLSchemes[.Facebook] else {
            preconditionFailure("Facebook Login not setup correctly")
        }
        presentOAuthSafariView(FacebookLoginProvider().authenticationRequestURL(scopes, urlScheme: urlScheme))
    }
    
    func handleCallbackURL(url: NSURL) -> Bool {
        for (prefix, socialProvider) in SocialLoginService.socialURLSchemePrefixes {
            if url.scheme.hasPrefix(prefix) {
                if let socialLoginResponseWrapped = try? SocialLoginService.socialProviderHandlers[socialProvider]?.getResponseFromCallbackURL(url), socialLoginResponse = socialLoginResponseWrapped {
                    switch socialLoginResponse.type {
                    case .AuthorizationCode:
                        stormpath.login(socialProvider: socialProvider, authorizationCode: socialLoginResponse.data, completionHandler: queuedCompletionHandler)
                    case .AccessToken:
                        stormpath.login(socialProvider: socialProvider, accessToken: socialLoginResponse.data, completionHandler: queuedCompletionHandler)
                    }
                    return true
                }
            }
        }
        return false
    }
    
    func presentOAuthSafariView(url: NSURL) {
        if #available(iOS 9, *) {
            let safari = SFSafariViewController(URL: url)
            UIApplication.sharedApplication().delegate?.window??.rootViewController?.presentViewController(safari, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}

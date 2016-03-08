//
//  SocialLoginService.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/4/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation
import SafariServices

/** 
 Social Login Service takes care of aspects of handling deep links intended for social login, as well as routing between different social providers.
*/
class SocialLoginService: NSObject {
    static let socialProviderHandlers: [StormpathSocialProvider: LoginProvider] = [.Facebook: FacebookLoginProvider(), .Google: GoogleLoginProvider()]
    
    weak var stormpath: Stormpath!
    var queuedCompletionHandler: StormpathSuccessCallback?
    
    var safari: UIViewController?
    
    init(withStormpath stormpath: Stormpath) {
        super.init()
        self.stormpath = stormpath
    }
    
    func beginLoginFlow(socialProvider: StormpathSocialProvider, completionHandler: StormpathSuccessCallback?) {
        guard let socialAppInfo = stormpath.configuration.socialProviderURLSchemes[socialProvider] else {
            preconditionFailure("Social Provider info could not be read from configuration. Did you add the URL scheme to Info.plist?")
        }
        queuedCompletionHandler = completionHandler
        let authenticationRequestURL = SocialLoginService.socialProviderHandlers[socialProvider]!.authenticationRequestURL(socialAppInfo)
        presentOAuthSafariView(authenticationRequestURL)
    }
    
    func handleCallbackURL(url: NSURL) -> Bool {
        safari?.dismissViewControllerAnimated(true, completion: nil)
        safari = nil
        
        // Check each prefix, and if there's one that matches, parse the response & login with the appropriate Stormpath social method
        for (socialProvider, handler) in SocialLoginService.socialProviderHandlers {
            if url.scheme.hasPrefix(handler.urlSchemePrefix) {
                guard let socialLoginResponse = (try? SocialLoginService.socialProviderHandlers[socialProvider]?.getResponseFromCallbackURL(url)) ?? nil else {
                    preconditionFailure("TODO: figure out error handling for rejected social login / malformed callback URLs")
                }
                
                switch socialLoginResponse.type {
                case .AuthorizationCode:
                    stormpath.login(socialProvider: socialProvider, authorizationCode: socialLoginResponse.data, completionHandler: queuedCompletionHandler)
                case .AccessToken:
                    stormpath.login(socialProvider: socialProvider, accessToken: socialLoginResponse.data, completionHandler: queuedCompletionHandler)
                }
                
                return true
            }
        }
        return false
    }
    
    private func presentOAuthSafariView(url: NSURL) {
        if #available(iOS 9, *) {
            safari = SFSafariViewController(URL: url)
            UIApplication.sharedApplication().delegate?.window??.rootViewController?.presentViewController(safari!, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}

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
        guard let socialAppInfo = stormpath.configuration.socialProviders[socialProvider] else {
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
                SocialLoginService.socialProviderHandlers[socialProvider]?.getResponseFromCallbackURL(url) { (response, error) -> Void in
                    guard let response = response where error == nil else {
                        dispatch_async(dispatch_get_main_queue(), {self.queuedCompletionHandler?(false, error)}) 
                        return
                    }
                    
                    switch response.type {
                    case .AuthorizationCode:
                        self.stormpath.login(socialProvider: socialProvider, authorizationCode: response.data, completionHandler: self.queuedCompletionHandler)
                    case .AccessToken:
                        self.stormpath.login(socialProvider: socialProvider, accessToken: response.data, completionHandler: self.queuedCompletionHandler)
                    }
                    self.queuedCompletionHandler = nil
                }
                return true
            }
        }
        queuedCompletionHandler = nil
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

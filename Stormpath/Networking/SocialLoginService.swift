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
    weak var stormpath: Stormpath!
    
    init(withStormpath stormpath: Stormpath) {
        super.init()
        self.stormpath = stormpath
    }
    
    func beginLoginFlow(socialProvider: StormpathSocialProvider, scopes: [String], completionHandler: StormpathSuccessCallback?) {
        guard socialProvider == .Facebook else {
            preconditionFailure("Other social providers not supported yet")
            return
        }
        
        guard let socialId = stormpath.configuration.socialProviderIds[.Facebook] else {
            preconditionFailure("Facebook Login not setup correctly")
        }
        let facebookOAuthURL = NSURL(string: "https://www.facebook.com/dialog/oauth?client_id=\(socialId)&redirect_uri=fb\(socialId)://authorize&response_type=token&scope=email")!
        presentOAuthSafariView(facebookOAuthURL)
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

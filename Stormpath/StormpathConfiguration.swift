//
//  StormpathConfig.swift
//  Stormpath
//
//  Created by Edward Jiang on 1/29/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

/**
 StormpathConfiguration is the class that manages the configuration for Stormpath, its endpoints, and API providers. It auto-loads
 from the configuration in Info.plist, or uses defaults that connect to a server on http://localhost:3000, the default in many Stormpath integrations.
 You can modify its properties directly.
 
 - note: The endpoints refer to the endpoints in the Stormpath Framework Spec. Use leading slashes to specify the endpoints.
 */
public class StormpathConfiguration {
    /// Singleton object representing the default configuration loaded from the config file. Used by the main Stormpath instance.
    public static var defaultConfiguration = StormpathConfiguration()
    
    /// Configuration parameter for the API URL. Do not use a trailing slash in the URL.
    public var APIURL = NSURL(string: "http://localhost:3000")!
    
    /// Endpoint for the current user context
    public var meEndpoint = "/me"
    
    /// Endpoint to request email verification
    public var verifyEmailEndpoint = "/verify"
    
    /// Endpoint to request a password reset email
    public var forgotPasswordEndpoint = "/forgot"
    
    /// Endpoint to create an OAuth token
    public var oauthEndpoint = "/oauth/token"
    
    /**
     Endpoint to logout
     
     - todo: this might not be needed, but I see it in Adis's code. I don't think hitting the /logout endpoint does anything?
     Not in the framework spec either.
     */
    public var logoutEndpoint = "/logout"
    
    /// Endpoint to register a new user
    public var registerEndpoint = "/register"
    
    public init() {
        guard let stormpathInfo = NSBundle.mainBundle().infoDictionary?["Stormpath"] as? [String: AnyObject] else {
            return
        }
        
        APIURL = (stormpathInfo["APIURL"] as? String)?.withoutTrailingSlash.asURL ?? APIURL
        
        guard let customEndpoints = stormpathInfo["customEndpoints"] as? [String: AnyObject] else {
            return
        }
        
        meEndpoint = (customEndpoints["me"] as? String)?.withLeadingSlash ?? meEndpoint
        verifyEmailEndpoint = (customEndpoints["verifyEmail"] as? String)?.withLeadingSlash ?? verifyEmailEndpoint
        forgotPasswordEndpoint = (customEndpoints["forgotPassword"] as? String)?.withLeadingSlash ?? forgotPasswordEndpoint
        oauthEndpoint = (customEndpoints["oauth"] as? String)?.withLeadingSlash ?? oauthEndpoint
        logoutEndpoint = (customEndpoints["logout"] as? String)?.withLeadingSlash ?? logoutEndpoint
        registerEndpoint = (customEndpoints["register"] as? String)?.withLeadingSlash ?? registerEndpoint
    }
}

/// Helper extensions to make the initializer easier.
private extension String {
    var withLeadingSlash: String {
        if hasPrefix("/") {
            return self
        } else {
            return "/" + self
        }
    }
    
    var withoutTrailingSlash: String {
        if hasSuffix("/") {
            return substringToIndex(endIndex.advancedBy(-1))
        } else {
            return self
        }
    }
    
    var asURL: NSURL? {
        return NSURL(string: self)
    }
}
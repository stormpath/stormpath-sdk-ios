//
//  StormpathConfig.swift
//  Stormpath
//
//  Created by Edward Jiang on 1/29/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

/**
 StormpathConfiguration is the class that manages the configuration for 
 Stormpath, its endpoints, and API providers. It auto-loads from the
 configuration in Info.plist, or uses defaults that connect to a server on
 http://localhost:3000, the default in many Stormpath integrations. You can
 modify its properties directly.
 
 - note: The endpoints refer to the endpoints in the Stormpath Framework Spec. 
   Use leading slashes to specify the endpoints.
 */
public class StormpathConfiguration: NSObject {
    /**
     Singleton object representing the default configuration loaded from the 
     config file. Used by the main Stormpath instance. Can be modified 
     programmatically.
     */
    public static var defaultConfiguration = StormpathConfiguration()
    
    /// Configuration parameter for the API URL.
    public var APIURL = URL(string: "http://localhost:3000")! {
        didSet {
            APIURL = APIURL.absoluteString.withoutTrailingSlash.asURL ?? APIURL
        }
    }
    
    /// Endpoint for the current user context
    public var meEndpoint = "/me" {
        didSet {
            meEndpoint = meEndpoint.withLeadingSlash
        }
    }
    
    /// Endpoint to request email verification
    public var verifyEmailEndpoint = "/verify" {
        didSet {
            verifyEmailEndpoint = verifyEmailEndpoint.withLeadingSlash
        }
    }
    
    /// Endpoint to request a password reset email
    public var forgotPasswordEndpoint = "/forgot" {
        didSet {
            forgotPasswordEndpoint = forgotPasswordEndpoint.withLeadingSlash
        }
    }
    
    /// Endpoint to create an OAuth token
    public var oauthEndpoint = "/oauth/token" {
        didSet {
            oauthEndpoint = oauthEndpoint.withLeadingSlash
        }
    }
    
    /**
     Endpoint to login
     */
    public var loginEndpoint = "/login" {
        didSet {
            loginEndpoint = loginEndpoint.withLeadingSlash
        }
    }
    
    /**
     Endpoint to logout
     */
    public var logoutEndpoint = "/logout" {
        didSet {
            logoutEndpoint = logoutEndpoint.withLeadingSlash
        }
    }
    
    /// Endpoint to register a new account
    public var registerEndpoint = "/register" {
        didSet {
            registerEndpoint = registerEndpoint.withLeadingSlash
        }
    }
    
    /// App IDs for social providers
    public var socialProviders = [StormpathSocialProvider: StormpathSocialProviderConfiguration]()
    
    /**
     Initializer for StormpathConfiguration. The initializer pulls defaults from 
     the Info.plist file, and falls back to default SDK values. Modify the 
     values after initialization to customize this object. 
     */
    public override init() {
        super.init()
        
        loadSocialProviderAppIds()
        loadStormpathConfigurationFromInfoPlist()
    }
    
    private func loadStormpathConfigurationFromInfoPlist() {
        guard let stormpathInfo = Bundle.main.infoDictionary?["Stormpath"] as? [String: AnyObject] else {
            return
        }
        
        APIURL = (stormpathInfo["APIURL"] as? String)?.asURL ?? APIURL
        
        guard let customEndpoints = stormpathInfo["customEndpoints"] as? [String: AnyObject] else {
            return
        }
        
        meEndpoint = (customEndpoints["me"] as? String) ?? meEndpoint
        verifyEmailEndpoint = (customEndpoints["verifyEmail"] as? String) ?? verifyEmailEndpoint
        forgotPasswordEndpoint = (customEndpoints["forgotPassword"] as? String) ?? forgotPasswordEndpoint
        oauthEndpoint = (customEndpoints["oauth"] as? String) ?? oauthEndpoint
        loginEndpoint = (customEndpoints["login"] as? String) ?? loginEndpoint
        logoutEndpoint = (customEndpoints["logout"] as? String) ?? logoutEndpoint
        registerEndpoint = (customEndpoints["register"] as? String) ?? registerEndpoint
    }
    
    private func loadSocialProviderAppIds() {
        
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: AnyObject]] else {
            return
        }
        
        // Convert the complex dictionary into an array of URL schemes
        let urlSchemes = urlTypes.flatMap({ ($0["CFBundleURLSchemes"] as? [String])?.first })
        
        // If there's a match, add it to the list of App IDs.
        for (socialProvider, handler) in SocialLoginService.socialProviderHandlers {
            if let urlScheme = urlSchemes.flatMap({$0.hasPrefix(handler.urlSchemePrefix) ? $0 : nil}).first, let appId = appIdFrom(urlScheme, socialProvider: socialProvider) {
                socialProviders[socialProvider] = StormpathSocialProviderConfiguration(appId: appId, urlScheme: urlScheme)
            }
        }
    }
    
    private func appIdFrom(_ urlScheme: String, socialProvider: StormpathSocialProvider) -> String? {
        switch socialProvider {
        case .facebook:
            // Turn fb12345 to 12345
            if let range = urlScheme.range(of: "\\d+", options: .regularExpression) {
                return urlScheme.substring(with: range)
            }
        case .google:
            // Turn com.googleusercontent.apps.[ID]-[SUFFIX] into 
            // [ID]-[SUFFIX]-.apps.googleusercontent.com, since Google likes
            // reversing things.
            
            return urlScheme.components(separatedBy: ".").reversed().joined(separator: ".")
        default:
            return nil
        }
        
        // Fallback if all else fails
        return nil
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
            return substring(to: characters.index(endIndex, offsetBy: -1))
        } else {
            return self
        }
    }
    
    var asURL: URL? {
        return URL(string: self)
    }
}

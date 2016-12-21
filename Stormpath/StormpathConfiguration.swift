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
@objc(SPHStormpathConfiguration)
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
    
    var urlScheme: String {
        return APIURL.host?.components(separatedBy: ".").reversed().joined(separator: ".") ?? ""
    }
    
    /**
     Initializer for StormpathConfiguration. The initializer pulls defaults from 
     the Info.plist file, and falls back to default SDK values. Modify the 
     values after initialization to customize this object. 
     */
    public override init() {
        super.init()
        
        loadStormpathConfigurationFromInfoPlist()
    }
    
    private func loadStormpathConfigurationFromInfoPlist() {
        guard let stormpathInfo = Bundle.main.infoDictionary?["Stormpath"] as? [String: AnyObject] else {
            return
        }
        
        APIURL = (stormpathInfo["APIURL"] as? String)?.asURL ?? APIURL
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

enum Endpoints: String {
    case me = "/me",
    register = "/register",
    login = "/login",
    oauthToken = "/oauth/token",
    oauthRevoke = "/oauth/revoke",
    forgot = "/forgot"
}

//
//  StormpathSocialProviderConfiguration.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/8/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

/// Configuration for a social provider (eg. Facebook, Google)
public class StormpathSocialProviderConfiguration: NSObject {
    /// URL Scheme the social provider will callback to
    public let urlScheme: String
    
    /// App ID for the social provider
    public let appId: String
    
    /// Scopes string formatted in the provider's format
    public var scopes: String?
    
    init(appId: String, urlScheme: String) {
        self.urlScheme = urlScheme
        self.appId = appId
    }
}
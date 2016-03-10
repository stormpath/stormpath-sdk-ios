//
//  StormpathSocialProvider.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/3/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

/// Social Login Providers
@objc public enum StormpathSocialProvider: Int {
    /// Facebook Login
    case Facebook
    
    /// Google Login
    case Google
    
    func stringValue() -> String {
        switch self {
        case .Facebook:
            return "facebook"
        case .Google:
            return "google"
        }
    }
}
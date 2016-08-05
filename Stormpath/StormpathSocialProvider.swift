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
    
    /// LinkedIn Login
    case LinkedIn
    
    /// GitHub Login
    case GitHub
    
    func stringValue() -> String {
        switch self {
        case .Facebook:
            return "facebook"
        case .Google:
            return "google"
        case .LinkedIn:
            return "linkedin"
        case .GitHub:
            return "github"
        }
    }
}
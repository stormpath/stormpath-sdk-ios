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
    case facebook
    
    /// Google Login
    case google
    
    func stringValue() -> String {
        switch self {
        case .facebook:
            return "facebook"
        case .google:
            return "google"
        }
    }
}

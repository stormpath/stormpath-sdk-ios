//
//  URLPaths.swift
//  Stormpath
//
//  Created by Adis on 23/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

internal enum URLPath: String {
    case Register       = "/register"
    case OAuth          = "/oauth/token"
    case UserProfile    = "/me"
    case Logout         = "/logout"
    case ResetPassword  = "/forgot"
    
    func URL(customPath: String?) -> NSURL {
        let baseURL: NSURL = NSURL(string: Stormpath.APIURL!)!
        
        guard let unwrappedPath = customPath where unwrappedPath.isEmpty == false else {
            let fullURL: NSURL = baseURL.URLByAppendingPathComponent(self.rawValue)
            
            return fullURL
        }
        
        return baseURL.URLByAppendingPathComponent(customPath!)
    }
}

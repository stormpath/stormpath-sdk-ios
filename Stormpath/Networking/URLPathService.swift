//
//  URLPathService.swift
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
    case PasswordReset  = "/forgot"
    
    func path(customPath: String?) -> String {
        guard customPath != nil && customPath?.isEmpty == false else {
            return URLPathService.urlStringForPath(self.rawValue)
        }
        
        return URLPathService.urlStringForPath(customPath!)
    }
}

internal final class URLPathService: NSObject {
    
    // MARK: Utility
    
    private class func urlStringForPath(path: String) -> String {
        
        let cleanPath = URLPathService.trimSlashesFromString(path)
        let fullPath = Stormpath.APIURL! + "/" + cleanPath
        
        return fullPath
        
    }
    
    private class func trimSlashesFromString(string: String) -> String {
        
        var cleanString = string
        
        while cleanString.hasSuffix("/") {
            cleanString = String(cleanString.characters.dropLast())
        }
        
        while cleanString.hasPrefix("/") {
            cleanString = String(cleanString.characters.dropFirst())
        }
        
        return cleanString
        
    }
    
}

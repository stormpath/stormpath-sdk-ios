//
//  URLPathService.swift
//  Stormpath
//
//  Created by Adis on 23/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

internal final class URLPathService: NSObject {
    
    // MARK: Convenience methods
    
    internal class func registerPath(relativeCustomPath: String?) -> String {
        
        if let unwrappedPath = relativeCustomPath {
            if unwrappedPath.isEmpty == false {
                return URLPathService.urlStringForPath(unwrappedPath)
            }
        }

        return URLPathService.urlStringForPath("/register")
    }
    
    internal class func loginPath(relativeCustomPath: String?) -> String {
        
        if let unwrappedPath = relativeCustomPath {
            if unwrappedPath.isEmpty == false {
                return URLPathService.urlStringForPath(unwrappedPath)
            }
        }
        
        return URLPathService.urlStringForPath("/oauth/token")
        
    }
    
    internal class func logoutPath(relativeCustomPath: String?) -> String {
        
        if let unwrappedPath = relativeCustomPath {
            if unwrappedPath.isEmpty == false {
                return URLPathService.urlStringForPath(unwrappedPath)
            }
        }
        
        return URLPathService.urlStringForPath("/logout")
        
    }
    
    // MARK: Utility
    
    private class func urlStringForPath(path: String) -> String {
        
        // TODO: Replace asserts with guards
        assert(Stormpath.APIURL.isEmpty == false, "Stormpath.APIURL needs to be set before calling API methods")
        assert(path.isEmpty == false, "Relative path must be provided")
        
        let cleanPath = URLPathService.trimSlashesFromString(path)
        let fullPath = Stormpath.APIURL + "/" + cleanPath
        
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

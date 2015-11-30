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
    
    // We can guarantee there will not be nil values here, the APIURL must be already set
    
    internal class func registerPath(relativeCustomPath: String?) -> String {
        
        guard relativeCustomPath != nil && relativeCustomPath?.isEmpty == false else {
            return URLPathService.urlStringForPath("/register")
        }
        
        return URLPathService.urlStringForPath(relativeCustomPath!)
        
    }
    
    internal class func loginPath(relativeCustomPath: String?) -> String {
        
        guard relativeCustomPath != nil && relativeCustomPath?.isEmpty == false else {
            return URLPathService.urlStringForPath("/oauth/token")
        }
        
        return URLPathService.urlStringForPath(relativeCustomPath!)
        
    }
    
    internal class func logoutPath(relativeCustomPath: String?) -> String {
        
        guard relativeCustomPath != nil && relativeCustomPath?.isEmpty == false else {
            return URLPathService.urlStringForPath("/logout")
        }
        
        return URLPathService.urlStringForPath(relativeCustomPath!)

    }
    
    internal class func passwordResetPath(relativeCustomPath: String?) -> String {
        guard relativeCustomPath != nil && relativeCustomPath?.isEmpty == false else {
            return URLPathService.urlStringForPath("/forgot")
        }
        
        return URLPathService.urlStringForPath(relativeCustomPath!)
    }
    
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

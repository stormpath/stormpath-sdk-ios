//
//  Logger.swift
//  Stormpath
//
//  Created by Adis on 27/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import Foundation

// Simple logging class flavored for this SDK

enum LogLevel {
    case None
    case Error
    case Debug
    case Verbose
}

final class Logger {
    
    static var logLevel: LogLevel {
        if _isDebugAssertConfiguration() {
            return .Debug
        } else {
            return .None
        }
    }
    
    class func log(string: String) {
        
        switch logLevel {
            case .None: break
                
            case .Debug, .Verbose, .Error:
                print("[STORMPATH] \(string)")
            }
        
    }
    
    class func logRequest(request: NSURLRequest) {
        
        if logLevel == .Debug || logLevel == .Verbose  {
            print("[STORMPATH] \(request.HTTPMethod!) \(request.URL!.absoluteString)")
            
            if logLevel == .Verbose {
                print("\(request.allHTTPHeaderFields!)")
                if let bodyData = request.HTTPBody, bodyString = String.init(data: bodyData, encoding: NSUTF8StringEncoding) {
                    print("\(bodyString)")
                }
            }
        }
        
    }
    
    class func logResponse(response: NSHTTPURLResponse, data: NSData?) {
        
        if logLevel == .Debug || logLevel == .Verbose  {
            print("[STORMPATH] \(response.statusCode) \(response.URL!.absoluteString)")
            
            if logLevel == .Verbose {
                print("\(response.allHeaderFields)")
                if let data = data {
                    print(String(data: data, encoding: NSUTF8StringEncoding)!)
                }
            }
        }
        
    }
    
    class func logError(error: NSError) {
        
        switch logLevel {
            case .None: break
                
            case .Debug, .Verbose, .Error:
                print("[STORMPATH][ERROR] \(error.code) \(error.localizedDescription)")
                print(error.userInfo)
        }
        
    }
    
}

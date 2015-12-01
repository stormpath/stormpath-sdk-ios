//
//  Logger.swift
//  Stormpath
//
//  Created by Adis on 27/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

// Simple logging class flavored for this SDK

public enum LogLevel {
    case None
    case Debug
    case Error
}

internal class Logger: NSObject {
    
    static let sharedLogger = Logger()
    var logLevel: LogLevel = .None
    
    private override init() {
        
    }
    
    internal func log(string: String) {
        
        switch self.logLevel {
        case .None:
            break
            
        case .Debug, .Error:
            print("[STORMPATH] \(string)")
            break
        }
        
    }
    
    internal func logRequest(request: NSURLRequest) {
        
        if self.logLevel == .Debug {
            print("[STORMPATH] \(request.HTTPMethod!) \(request.URL!.absoluteString) \n\(request.allHTTPHeaderFields!)")
        }
        
    }
    
    internal func logResponse(response: NSHTTPURLResponse, data: NSData?) {
        
        if self.logLevel == .Debug {
            print("[STORMPATH] \(response.statusCode) \(response.URL!.absoluteString) \n\(response.allHeaderFields)")
            if data != nil {
                print(String(data: data!, encoding: NSUTF8StringEncoding)!)
            }
        }
        
    }
    
    internal func logError(error: NSError) {
        
        switch self.logLevel {
            case .None:
                break
                
            case .Debug, .Error:
                print("[STORMPATH][ERROR] \(error.code) \(error.localizedDescription)")
                break
        }
        
    }
    
}

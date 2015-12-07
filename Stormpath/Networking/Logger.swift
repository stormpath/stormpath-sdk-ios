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
    
    static var logLevel: LogLevel = .None
    
    private override init() {
        
    }
    
    internal class func log(string: String) {
        
        switch self.logLevel {
        case .None:
            break
            
        case .Debug, .Error:
            print("[STORMPATH] \(string)")
            break
        }
        
    }
    
    internal class func logRequest(request: NSURLRequest) {
        
        if self.logLevel == .Debug {
            print("[STORMPATH] \(request.HTTPMethod!) \(request.URL!.absoluteString) \n\(request.allHTTPHeaderFields!)")
            if let bodyData = request.HTTPBody, bodyString = String.init(data: bodyData, encoding: NSUTF8StringEncoding) {
                print(bodyString)
            }
        }
        
    }
    
    internal class func logResponse(response: NSHTTPURLResponse, data: NSData?) {
        
        if self.logLevel == .Debug {
            print("[STORMPATH] \(response.statusCode) \(response.URL!.absoluteString) \n\(response.allHeaderFields)")
            if data != nil {
                print(String(data: data!, encoding: NSUTF8StringEncoding)!)
            }
        }
        
    }
    
    internal class func logError(error: NSError) {
        
        switch self.logLevel {
            case .None:
                break
                
            case .Debug, .Error:
                print("[STORMPATH][ERROR] \(error.code) \(error.localizedDescription)")
                break
        }
        
    }
    
}

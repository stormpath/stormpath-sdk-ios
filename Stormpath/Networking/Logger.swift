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
    case Info
    case Error
}

internal class Logger: NSObject {
    
    static let sharedLogger = Logger()
    var loggingEnabled: Bool = true
    
    private override init() {
        
    }
    
    internal func log(string: String) {
        
        if self.loggingEnabled {
            print("[Stormpath] " + string)
        }
        
    }
    
    internal func logRequest(request: NSURLRequest, title: String) {
        
        if self.loggingEnabled {
            debugPrint("[Stormpath] ", title)
            debugPrint(request)
        }
        
    }
    
    internal func logResponse(response: NSURLResponse, title: String) {
        
        if self.loggingEnabled {
            debugPrint("[Stormpath] ", title)
            debugPrint(response)
        }
        
    }
    
}

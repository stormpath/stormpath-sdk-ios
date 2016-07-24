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
    case none
    case error
    case debug
    case verbose
}

final class Logger {
	
    static let logLevels: [Bool:LogLevel] = [false: .debug, true: .none]
    static let logLevel = logLevels[_isDebugAssertConfiguration()]!
    
    class func log(_ string: String) {
        
        switch logLevel {
            case .none: break
                
            case .debug, .verbose, .error:
                print("[STORMPATH] \(string)")
            }
        
    }
    
    class func logRequest(_ request: URLRequest) {
        
        if logLevel == .debug || logLevel == .verbose  {
            print("[STORMPATH] \(request.httpMethod!) \(request.url!.absoluteString)")
            
            if logLevel == .verbose {
                print("\(request.allHTTPHeaderFields!)")
                if let bodyData = request.httpBody, let bodyString = String.init(data: bodyData, encoding: String.Encoding.utf8) {
                    print("\(bodyString)")
                }
            }
        }
        
    }
    
    class func logResponse(_ response: HTTPURLResponse, data: Data?) {
        
        if logLevel == .debug || logLevel == .verbose  {
            print("[STORMPATH] \(response.statusCode) \(response.url!.absoluteString)")
            
            if logLevel == .verbose {
                print("\(response.allHeaderFields)")
                if let data = data {
                    print(String(data: data, encoding: String.Encoding.utf8)!)
                }
            }
        }
        
    }
    
    class func logError(_ error: NSError) {
        
        switch logLevel {
            case .none: break
                
            case .debug, .verbose, .error:
                print("[STORMPATH][ERROR] \(error.code) \(error.localizedDescription)")
                print(error.userInfo)
        }
        
    }
    
}

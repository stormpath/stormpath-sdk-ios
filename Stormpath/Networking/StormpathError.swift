//
//  StormpathError.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/9/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

let StormpathErrorDomain = "StormpathErrorDomain"

public class StormpathError: NSError {
    static let InternalSDKError = StormpathError(code: 0, description: "Internal SDK Error")
    static let APIResponseError = StormpathError(code: 1, description: "Unrecognized API Response")
    
    class func errorForResponse(response: NSHTTPURLResponse, data: NSData?) -> StormpathError {
        var description = ""
        if let data = data, json = try? NSJSONSerialization.JSONObjectWithData(data, options: []), errorDescription = json["error"] as? String {
            description = errorDescription
        } else {
            description = "Invalid Server Response"
        }
        return StormpathError(code: response.statusCode, description: description)
    }
    
    init(code: Int, description: String) {
        var userInfo = [String: AnyObject]()
        userInfo[NSLocalizedDescriptionKey] = description
        
        super.init(domain: StormpathErrorDomain, code: code, userInfo: userInfo)
        
        Logger.logError(self)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
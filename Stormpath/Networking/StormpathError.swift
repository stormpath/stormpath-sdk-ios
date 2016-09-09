//
//  StormpathError.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/9/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

let StormpathErrorDomain = "StormpathErrorDomain"

/**
 StormpathError represents an error that can be passed back by a Stormpath API 
 after a network response. It typically contains a HTTP status code, along with 
 a localizedDescription of the specific error as passed back by the Framework 
 Integration API. It also has two special error codes: 
 
 0 - Internal SDK Error (which should be reported to Stormpath as a bug)
 1 - Unrecognized API Response (which means the Framework integration may not 
 support this version of Stormpath)
*/

public class StormpathError: NSError {
    /**
     Internal SDK Error represents errors that should not have occurred and are
     likely a bug with the Stormpath SDK.
     */
    static let InternalSDKError = StormpathError(code: 0, description: "Internal SDK Error")
    
    /**
     API Response Error represents errors that occurred because the API didn't 
     respond in a recognized way. Check that the SDK is configured to hit a 
     correct endpoint, or that the Framework integration is a compatible 
     version.
     */
    static let APIResponseError = StormpathError(code: 1, description: "Unrecognized API Response")
     
    /**
     Converts a Framework Integration error response into a StormpathError 
     object.
     */
    class func errorForResponse(_ response: HTTPURLResponse, data: Data) -> StormpathError {
        var description = ""
        if let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any], let errorDescription = json["message"] as? String {
            description = errorDescription
        } else if response.statusCode == 401 {
            description = "Unauthorized"
        } else {
            return StormpathError.APIResponseError
        }
        return StormpathError(code: response.statusCode, description: description)
    }
    
    /**
     Initializer for StormpathError
     
     - parameters:
       - code: HTTP Error code for the error.
       - description: Localized description of the error.
     */
    init(code: Int, description: String) {
        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = description
        
        super.init(domain: StormpathErrorDomain, code: code, userInfo: userInfo)
        
        Logger.logError(self)
    }

    /// Not implemented, do not use. 
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

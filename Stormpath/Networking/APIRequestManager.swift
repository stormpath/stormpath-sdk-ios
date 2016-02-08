//
//  APIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

class APIRequestManager: NSObject {
    var url: NSURL
    var request = NSMutableURLRequest()
    
    init(withURL url: NSURL) {
        self.url = url
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    func begin() {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: requestDidFinish)
        task.resume()
    }
    
    func prepareForRequest() {
        preconditionFailure("Method not implemented")
    }
    
    func requestDidFinish(data: NSData?, response: NSURLResponse?, error: NSError?) {
        preconditionFailure("Method not implemented")
    }
    
    func setAccessToken(accessToken: String) {
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
    }
    
    class func parseDictionaryResponseData(data: NSData?, completionHandler: CompletionBlockWithDictionary) {
        // First make sure there are no network errors
        guard let data = data else {
            Logger.log("Uh-oh. Apparently, there were no errors, or data in your API response. This shouldn't have happened.")
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(nil, nil)
            })
            
            return
        }
        
        // Attempt to parse the response JSON
        do {
            if let userResponseDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(userResponseDictionary, nil)
                })
            }
        } catch let error as NSError {
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(nil, error)
            })
        }
    }
    
    class func errorForResponse(response: NSHTTPURLResponse, data: NSData?) -> NSError {
        var userInfo = [String: AnyObject]()
        
        userInfo[NSLocalizedFailureReasonErrorKey] = NSHTTPURLResponse.localizedStringForStatusCode(response.statusCode)
        
        // If the API returned an error object, extract the reason and put it in the error description instead
        if let data = data where data.length > 0 {
            let errorDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
            if let errorDescription = errorDictionary["error"] {
                userInfo[NSLocalizedDescriptionKey] = errorDescription
            }
        }
        
        let error: NSError = NSError(domain: "", code: response.statusCode, userInfo: userInfo)
        Logger.logError(error)
        
        return error
    }
}

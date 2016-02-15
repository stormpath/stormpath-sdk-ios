//
//  APIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class APIRequestManager: NSObject {
    var request = NSMutableURLRequest()
    
    init(withURL url: NSURL) {
        request.URL = url
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue("stormpath-sdk-swift/" + version, forHTTPHeaderField: "X-Stormpath-Agent")
        }
    }
    
    func requestDidFinish(data: NSData, response: NSHTTPURLResponse) {
        preconditionFailure("Method not implemented")
    }
    
    func executeCallback(parameters: AnyObject?, error: NSError?) {
        preconditionFailure("Method not implemented")
    }
    
    func prepareForRequest() {
    }
    
    func begin() {
        prepareForRequest()
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: requestCompletionHandler)
        task.resume()
    }
    
    func setAccessToken(accessToken: String) {
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
    }
    
    private func requestCompletionHandler(data: NSData?, response: NSURLResponse?, error: NSError?) {
        guard let response = response as? NSHTTPURLResponse, data = data where error == nil else {
            if let error = error {
                Logger.logError(error)
            }
            self.executeCallback(nil, error: error)
            return
        }
        
        Logger.logResponse(response, data: data)
        
        //If the status code isn't 2XX
        if response.statusCode / 100 != 2 {
            self.executeCallback(nil, error: StormpathError.errorForResponse(response, data: data))
        } else {
            requestDidFinish(data, response: response)
        }
    }
}

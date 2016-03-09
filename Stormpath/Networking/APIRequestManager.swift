//
//  APIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class APIRequestManager: NSObject {
    let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    var request = NSMutableURLRequest()
    
    init(withURL url: NSURL) {
        request.URL = url
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let version = NSBundle(forClass: APIRequestManager.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue("stormpath-sdk-ios/" + version + " iOS/" + UIDevice.currentDevice().systemVersion, forHTTPHeaderField: "X-Stormpath-Agent")
        }
    }
    
    func requestDidFinish(data: NSData, response: NSHTTPURLResponse) {
        preconditionFailure("Method not implemented")
    }
    
    func performCallback(error error: NSError?) {
        preconditionFailure("Method not implemented")
    }
    
    func prepareForRequest() {
    }
    
    func begin() {
        prepareForRequest()
        let task = urlSession.dataTaskWithRequest(request, completionHandler : requestCompletionHandler)
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
            self.performCallback(error: error)
            return
        }
        
        Logger.logResponse(response, data: data)
        
        //If the status code isn't 2XX
        if response.statusCode / 100 != 2 {
            self.performCallback(error: StormpathError.errorForResponse(response, data: data))
        } else {
            requestDidFinish(data, response: response)
        }
    }
}

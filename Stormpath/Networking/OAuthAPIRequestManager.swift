//
//  OAuthAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

typealias OAuthAPIRequestCallback = ((String?, NSError?) -> Void)

class OAuthAPIRequestManager: APIRequestManager {
    var requestBody: String
    var callback: OAuthAPIRequestCallback
    
    private init(withURL url: NSURL, requestBody: String, callback: OAuthAPIRequestCallback) {
        self.requestBody = requestBody
        self.callback = callback
        
        super.init(withURL: url)
    }
    
    convenience init(withURL url: NSURL, username: String, password: String, callback: OAuthAPIRequestCallback) {
        let requestBody = String(format: "username=%@&password=%@&grant_type=password",
            APIService._URLEncodedString(username),
            APIService._URLEncodedString(password))
        
        self.init(withURL: url, requestBody: requestBody, callback: callback)
    }
    
    convenience init(withURL url: NSURL, refreshToken: String, callback: OAuthAPIRequestCallback) {
        let requestBody = String(format: "refresh_token=%@&grant_type=refresh_token", refreshToken)
        
        self.init(withURL: url, requestBody: requestBody, callback: callback)
    }
    
    override func prepareForRequest() -> NSMutableURLRequest {
        let request = super.prepareForRequest()
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = requestBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        return request
    }
    
    override func requestDidFinish(data: NSData?, response: NSURLResponse?, error: NSError?) {
        guard let response = response where error == nil else {
            Logger.logError(error!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.callback(nil, error)
            })
    
            return
        }
    
        let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
        Logger.logResponse(HTTPResponse, data: data)
    
        if HTTPResponse.statusCode != 200 {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.callback(nil, APIService._errorForResponse(HTTPResponse, data: data))
            })
        } else {
            APIService.parseLoginResponseData(data, completionHandler: callback)
        }
    }
}
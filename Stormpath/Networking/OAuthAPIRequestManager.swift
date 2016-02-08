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
        let requestBody = "username=\(username.formURLEncoded)&password=\(password.formURLEncoded)&grant_type=password"
        
        self.init(withURL: url, requestBody: requestBody, callback: callback)
    }
    
    convenience init(withURL url: NSURL, refreshToken: String, callback: OAuthAPIRequestCallback) {
        let requestBody = String(format: "refresh_token=%@&grant_type=refresh_token", refreshToken)
        
        self.init(withURL: url, requestBody: requestBody, callback: callback)
    }
    
    override func prepareForRequest() {
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = requestBody.dataUsingEncoding(NSUTF8StringEncoding)
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
                self.callback(nil, APIRequestManager.errorForResponse(HTTPResponse, data: data))
            })
        } else {
            OAuthAPIRequestManager.parseLoginResponseData(data, completionHandler: callback)
        }
    }
    
    private class func parseLoginResponseData(data: NSData?, completionHandler: CompletionBlockWithString) {
        
        guard let data = data else {
            Logger.log("Uh-oh. Apparently, there were no errors, or data in your API response. This shouldn't have happened.")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(nil, nil)
            })
            
            return
        }
        
        do {
            if let tokensDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                // Extract the access_token
                if let accessToken: String = tokensDictionary["access_token"] as? String {
                    KeychainService.accessToken = accessToken
                    
                    // If there was an access_token, check for the refresh_token as well
                    if let refreshToken: String = tokensDictionary["refresh_token"] as? String {
                        KeychainService.refreshToken = refreshToken
                    } else {
                        Logger.log("There was no refresh_token present in the response!")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(accessToken, nil)
                    })
                } else {
                    Logger.log("There was no access_token present in the response!")
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(nil, nil)
                    })
                }
            } else {
                completionHandler(nil, nil)
            }
        } catch let error as NSError {
            dispatch_async(dispatch_get_main_queue(), {
                Logger.logError(error)
                completionHandler(nil, error)
            })
        }
    }
}


// There's an argument to be made for this to be a string category, but since this is the only method and only needed for this class...

// Custom URL encode, 'cos iOS is missing one. This one is blatantly stolen from AFNetworking's implementation of percent escaping and converted to Swift

private extension String {
    var formURLEncoded: String {
        let charactersGeneralDelimitersToEncode = ":#[]@"
        let charactersSubDelimitersToEncode     = "!$&'()*+,;="
        
        let allowedCharacterSet: NSMutableCharacterSet = NSCharacterSet.URLHostAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        
        allowedCharacterSet.removeCharactersInString(charactersGeneralDelimitersToEncode.stringByAppendingString(charactersSubDelimitersToEncode))
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet)!
    }
}
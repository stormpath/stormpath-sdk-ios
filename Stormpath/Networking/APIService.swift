//
//  APIService.swift
//  Stormpath
//
//  Created by Adis on 18/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

internal class APIService: NSObject {
    
    internal class func requestWithURLString(URLString: String) -> NSMutableURLRequest {
        
        let URL: NSURL = NSURL.init(string: URLString)!
        let request: NSMutableURLRequest = NSMutableURLRequest.init(URL: URL)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
        
    }
    
    // MARK: Registration
    
    internal class func register(customPath: String?, userDictionary: NSDictionary, completion: CompletionBlockWithDictionary) {
        
        let URLString = URLPathService.registerPath(customPath)
        let request: NSMutableURLRequest = APIService.requestWithURLString(URLString)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(userDictionary, options: [])
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            APIService.parseResponseData(data, error: error, completion: completion)
        }
        
        task.resume()
        
    }
    
    // MARK: Login
    
    internal class func login(customPath: String?, username: String, password: String, completion: CompletionBlockWithString) {
        
        let URLString = URLPathService.loginPath(customPath)
        let request: NSMutableURLRequest = APIService.requestWithURLString(URLString)
        
        // Generate the form data, the data posted MUST be a form
        let body: String = String(format: "username=%@&password=%@&grant_type=password", username, password)
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if error == nil {
                if let responseData = data {
                    do {
                        let tokensDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as! NSDictionary
                        
                        
                        if let accessToken: String = tokensDictionary["access_token"] as? String {
                            KeychainService.accessToken = accessToken
                            
                            if let refreshToken: String = tokensDictionary["refresh_token"] as? String {
                                KeychainService.refreshToken = refreshToken
                            } else {
                                // LOG
                            }
                            
                            completion(accessToken, nil)
                        } else {
                            // LOG
                        }
                        
                    } catch let error as NSError {
                        completion(nil, error)
                    }
                } else {
                    // LOG
                }
            } else {
                completion(nil, error)
            }
            
        }
        
        task.resume()
        
    }
    
    // MARK: Logout
    
    internal class func logout(customPath: String?, completion: CompletionBlockWithError) {
        
        let URLString = URLPathService.logoutPath(customPath)
        let request: NSMutableURLRequest = APIService.requestWithURLString(URLString)
        request.HTTPMethod = "GET"
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completion(error)
            })
        }
        
        task.resume()
        
    }
    
    // MARK: Access token refresh
    
    internal class func refreshAccessToken(completion: CompletionBlockWithString) {
        
        // TODO: Implement me
        completion("new_token", nil)
        
    }
    
    // MARK: Parse response data
    
    internal class func parseResponseData(data: NSData?, error: NSError?, completion: CompletionBlockWithDictionary) -> Void {
        
        // First make sure there are no network errors
        guard error == nil && data != nil else {
            dispatch_async(dispatch_get_main_queue(), {
                completion(nil, error)
            })
            return
        }
        
        do {
            if let userResponseDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(userResponseDictionary, nil)
                })
            }
        } catch let error as NSError {
            dispatch_async(dispatch_get_main_queue(), {
                completion(nil, error)
            })
        }
        
    }
    
}

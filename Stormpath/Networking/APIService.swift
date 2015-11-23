//
//  APIService.swift
//  Stormpath
//
//  Created by Adis on 18/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

class APIService: NSObject {
    
    class func requestWithURLString(URLString: String) -> NSMutableURLRequest {
        
        let URL: NSURL = NSURL.init(string: URLString)!
        let request: NSMutableURLRequest = NSMutableURLRequest.init(URL: URL)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
        
    }
    
    // MARK: Registration
    
    class func register(customPath: String?, userDictionary: NSDictionary, completion: CompletionBlockWithDictionary) {
        
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
    
    class func login(customPath: String?, username: String, password: String, completion: CompletionBlockWithDictionary) {
        
        // FIXME: Logout before login, otherwise no new tokens are fetched?
        
        let URLString = URLPathService.loginPath(customPath)
        let request: NSMutableURLRequest = APIService.requestWithURLString(URLString)
        
        let params: NSDictionary = ["username": username, "password": password]
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
            
            if let cookieString = HTTPResponse.allHeaderFields["Set-Cookie"] {
                // TODO: Parse the tokens, save them, then call completion
                // There may be a better way to get the tokens though
                print(cookieString)
            } else {
                // TODO: Add handling of missing tokens
                completion(nil, nil)
            }
            
        }
        
        task.resume()
        
    }
    
    class func logout(customPath: String?, completion: CompletionBlockWithError) {
        
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
    
    // MARK: Parse response data
    
    class func parseResponseData(data: NSData?, error: NSError?, completion: CompletionBlockWithDictionary) -> Void {
        
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

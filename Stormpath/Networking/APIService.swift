//
//  APIService.swift
//  Stormpath
//
//  Created by Adis on 18/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

class APIService: NSObject {
    
    class func requestWithURL(URLString: String) -> NSMutableURLRequest {
        
        assert(Stormpath.APIURL.isEmpty == false, "Stormpath.APIURL needs to be set before calling API methods")
        
        let URLString: String = Stormpath.APIURL.stringByAppendingString(URLString)
        let URL: NSURL = NSURL.init(string: URLString)!
        let request: NSMutableURLRequest = NSMutableURLRequest.init(URL: URL)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
        
    }
    
    // MARK: Registration
    
    class func register(userDictionary: NSDictionary, completion: CompletionBlockWithDictionary) {
        
        let request: NSMutableURLRequest = APIService.requestWithURL("/register")
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(userDictionary, options: [])
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            APIService.parseResponseData(data, error: error, completion: completion)
        }
        
        task.resume()
        
    }
    
    // MARK: Login
    
    class func login(username: String, password: String, completion: CompletionBlockWithDictionary) {
        
        let request: NSMutableURLRequest = APIService.requestWithURL("/login")
        let params: NSDictionary = ["username": username, "password": password]
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            print(String.init(data: data!, encoding: NSUTF8StringEncoding))
            print(response)
            APIService.parseResponseData(data, error: error, completion: completion)
        }
        
        task.resume()
        
    }
    
    class func logout(completion: CompletionBlockWithError) {
        
        let request: NSMutableURLRequest = APIService.requestWithURL("/logout")
        request.HTTPMethod = "GET"
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            print(String.init(data: data!, encoding: NSUTF8StringEncoding))
            print(response)
            print(error?.localizedDescription)
            
            completion(error)
        }
        
        task.resume()
        
    }
    
    // MARK: Parse response data
    
    class func parseResponseData(data: NSData?, error: NSError?, completion: CompletionBlockWithDictionary) -> Void {
        
        // First make sure there are no network errors
        guard error == nil && data != nil else {
            completion(nil, error)
            return
        }
        
        do {
            if let userResponseDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                completion(userResponseDictionary, nil)
            }
        } catch let error as NSError {
            completion(nil, error)
        }
        
    }
    
}

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
    
    // TODO: Refactor this using enums, might turn out to be more elegant solution
    
    class func register(username: String, password: String, completion: CompletionBlock) {
        
        let request: NSMutableURLRequest = APIService.requestWithURL("/register")
        let params: NSDictionary = ["email": username, "password": password]
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            print(String.init(data: data!, encoding: NSUTF8StringEncoding))
            print(response)
            print(error?.localizedDescription)
            
            completion(true, error)
        }
        
        task.resume()
        
    }
    
    // The reason this method is separated from above is that register might take more parameters in the future
    
    class func login(username: String, password: String, completion: CompletionBlock) {
        
        let request: NSMutableURLRequest = APIService.requestWithURL("/login")
        let params: NSDictionary = ["username": username, "password": password]
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            print(String.init(data: data!, encoding: NSUTF8StringEncoding))
            print(response)
            print(error?.localizedDescription)
            
            completion(true, error)
        }
        
        task.resume()
        
    }
    
    class func logout(completion: CompletionBlock) {
        
        let request: NSMutableURLRequest = APIService.requestWithURL("/logout")
        request.HTTPMethod = "GET"
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            print(String.init(data: data!, encoding: NSUTF8StringEncoding))
            print(response)
            print(error?.localizedDescription)
            
            completion(true, error)
        }
        
        task.resume()
        
    }
    
}

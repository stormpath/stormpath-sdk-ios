//
//  APIService.swift
//  Stormpath
//
//  Created by Adis on 18/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

internal let CustomRegisterPath: String         = "customRegisterPath"
internal let CustomLoginRefreshPath: String     = "customOAuthPath"
internal let CustomLogoutPath: String           = "customLogoutPath"
internal let CustomResetPasswordPath: String    = "customResetPasswordPath"

internal class APIService: NSObject {
    
    // Store the custom paths so we can use them without needing to pass them around all the time
    
    internal class var customRegisterPath: String {
        get {
            if let storedValue = KeychainService.stringForKey(CustomRegisterPath) {
                return storedValue
            } else {
                return ""
            }
        }
        
        set {
            KeychainService.saveString(newValue, key: CustomRegisterPath)
        }
    }
    
    internal class var customLoginRefreshPath: String {
        get {
            if let storedValue = KeychainService.stringForKey(CustomLoginRefreshPath) {
                return storedValue
            } else {
                return ""
            }
        }
        
        set {
            KeychainService.saveString(newValue, key: CustomLoginRefreshPath)
        }
    }
    
    internal class var customLogoutPath: String {
        get {
            if let storedValue = KeychainService.stringForKey(CustomLogoutPath) {
                return storedValue
            } else {
                return ""
            }
        }
        
        set {
            KeychainService.saveString(newValue, key: CustomLogoutPath)
        }
    }
    
    internal class var customResetPasswordPath: String {
        get {
            if let storedValue = KeychainService.stringForKey(CustomResetPasswordPath) {
                return storedValue
            } else {
                return ""
            }
        }
        
        set {
            KeychainService.saveString(newValue, key: CustomResetPasswordPath)
        }
    }
    
    internal class func requestWithURLString(URLString: String) -> NSMutableURLRequest {
        
        let URL: NSURL = NSURL.init(string: URLString)!
        let request: NSMutableURLRequest = NSMutableURLRequest.init(URL: URL)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
        
    }
    
    // MARK: Registration
    
    internal class func register(customPath: String?, userDictionary: Dictionary<String, String>, completion: CompletionBlockWithDictionary) {
        
        if customPath != nil {
            self.customRegisterPath = customPath!
        }
        
        let URLString = URLPathService.registerPath(customPath)
        let request: NSMutableURLRequest = self.requestWithURLString(URLString)
        
        request.HTTPMethod = "POST"
        
        Logger.logRequest(request)
        
        if let HTTPBodyData: NSData = try! NSJSONSerialization.dataWithJSONObject(userDictionary, options: []) {
            request.HTTPBody = HTTPBodyData
            
            let session: NSURLSession = NSURLSession.sharedSession()
            
            let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                guard response != nil && error == nil else {
                    Logger.logError(error!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(nil, error)
                    })
                    
                    return
                }
                
                let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
                Logger.logResponse(HTTPResponse, data: data)
                
                if HTTPResponse.statusCode != 200 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(nil, self.errorForResponse(HTTPResponse, data: data))
                    })
                } else {
                    self.parseRegisterHeaderData(HTTPResponse, completion: { (headersParsed) -> () in
                        self.parseRegisterResponseData(data, completion: completion)
                    })
                }
            }
            
            task.resume()
        } else {
            Logger.log("NSJSONSerialization failed to convert Dictionary to JSON Object")
        }
    }
    
    // MARK: Login
    
    internal class func login(customPath: String?, username: String, password: String, completion: CompletionBlockWithString) {
        
        if customPath != nil {
            self.customLoginRefreshPath = customPath!
        }
        
        let URLString = URLPathService.loginPath(self.customLoginRefreshPath)
        let request: NSMutableURLRequest = self.requestWithURLString(URLString)
        
        // Generate the form data, the data posted MUST be a form
        let body: String = String(format: "username=%@&password=%@&grant_type=password", username, password)
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        Logger.logRequest(request)
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard response != nil && error == nil else {
                Logger.logError(error!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(nil, error)
                })
                
                return
            }
            
            let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
            Logger.logResponse(HTTPResponse, data: data)
            
            if HTTPResponse.statusCode != 200 {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(nil, self.errorForResponse(HTTPResponse, data: data))
                })
            } else {
                self.parseLoginResponseData(data, completion: completion)
            }
        }
        
        task.resume()
        
    }
    
    // MARK: Access token refresh
    
    internal class func refreshAccessToken(customPath: String?, completion: CompletionBlockWithString) {
        
        if customPath != nil {
            self.customLoginRefreshPath = customPath!
        }
        
        let URLString = URLPathService.loginPath(self.customLoginRefreshPath)
        let request: NSMutableURLRequest = self.requestWithURLString(URLString)
        
        // Generate the form data, the data posted MUST be a form
        if let refreshToken = KeychainService.refreshToken {
            let body: String = String(format: "refresh_token=%@&grant_type=refresh_token", refreshToken)
            
            request.HTTPMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
            
            Logger.logRequest(request)
            
            let session: NSURLSession = NSURLSession.sharedSession()
            
            let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                guard response != nil && error == nil else {
                    Logger.logError(error!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(nil, error)
                    })
                    
                    return
                }
                
                let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
                Logger.logResponse(HTTPResponse, data: data)
                
                if HTTPResponse.statusCode != 200 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(nil, self.errorForResponse(HTTPResponse, data: data))
                    })
                } else {
                    self.parseLoginResponseData(data, completion: completion)
                }
            }
            
            task.resume()
        } else {
            let error = NSError(domain: URLString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(nil, error)
            })
        }
        
    }
    
    // MARK: Logout
    
    internal class func logout(customPath: String?, completion: CompletionBlockWithError) {
        
        if customPath != nil {
            self.customLogoutPath = customPath!
        }
        
        let URLString = URLPathService.logoutPath(customPath)
        let request: NSMutableURLRequest = self.requestWithURLString(URLString)
        request.HTTPMethod = "GET"
        
        Logger.logRequest(request)
        
        // Regardless of how the API calls goes, we can logout the user locally
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard response != nil && error == nil else {
                Logger.logError(error!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(error)
                })
                
                return
            }
            
            Logger.logResponse(response as! NSHTTPURLResponse, data: data)
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(error)
            })
        }
        
        task.resume()
        
    }
    
    // MARK: Forgot password
    
    internal class func resetPassword(customPath: String?, email: String, completion: CompletionBlockWithError) {
        
        if customPath != nil {
            self.customResetPasswordPath = customPath!
        }
     
        let URLString = URLPathService.passwordResetPath(customPath)
        let request: NSMutableURLRequest = self.requestWithURLString(URLString)
        
        request.HTTPMethod = "POST"
        
        Logger.logRequest(request)
        
        let emailDictionary: Dictionary = ["email": email]
        
        if let HTTPBodyData: NSData = try! NSJSONSerialization.dataWithJSONObject(emailDictionary, options: []) {
            request.HTTPBody = HTTPBodyData
            
            Logger.logRequest(request)
            
            let session: NSURLSession = NSURLSession.sharedSession()
            
            let task: NSURLSessionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                guard response != nil && error == nil else {
                    Logger.logError(error!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(error)
                    })
                    
                    return
                }
                
                Logger.logResponse(response as! NSHTTPURLResponse, data: data)
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion(error)
                })
            }
            
            task.resume()
        } else {
            Logger.log("NSJSONSerialization failed to convert Dictionary to JSON Object")
        }
        
    }
    
    // MARK: Parse response data
    
    internal class func parseRegisterHeaderData(response: NSHTTPURLResponse, completion: ((Bool) -> ())) {
        if let headerFields = response.allHeaderFields as? [String: String], cookies: [NSHTTPCookie] = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: response.URL!) {
            
            var foundToken: Bool = false
            
            for cookie in cookies {
                if cookie.name == "access_token" {
                    KeychainService.saveString(cookie.value, key: AccessTokenKey)
                    foundToken = true
                }
                
                if cookie.name == "refresh_token" {
                    KeychainService.saveString(cookie.value, key: RefreshTokenKey)
                }
            }
            
            if (foundToken == false) {
                Logger.log("There was no access_token in the register cookies, if you want to skip the login after registration, enable the autologin in your Express app.")
            }
            
            completion(foundToken)
        } else {
            Logger.log("There was no access_token in the register cookies, if you want to skip the login after registration, enable the autologin in your Express app.")
            completion(false)
        }
    }
    
    internal class func parseRegisterResponseData(data: NSData?, completion: CompletionBlockWithDictionary) {
        
        // First make sure there are no network errors
        guard data != nil else {
            Logger.log("Uh-oh. Apparently, there were no errors, or data in your API response. This shouldn't have happened.")
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(nil, nil)
            })
            
            return
        }
        
        // Attempt to parse the response JSON
        do {
            if let userResponseDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(userResponseDictionary, nil)
                })
            }
        } catch let error as NSError {
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(nil, error)
            })
        }

    }
    
    internal class func parseLoginResponseData(data: NSData?, completion: CompletionBlockWithString) {
        
        guard data != nil else {
            Logger.log("Uh-oh. Apparently, there were no errors, or data in your API response. This shouldn't have happened.")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(nil, nil)
            })
            
            return
        }
        
        do {
            if let tokensDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
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
                        completion(accessToken, nil)
                    })
                } else {
                    Logger.log("There was no access_token present in the response!")
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(nil, nil)
                    })
                }
            } else {
                completion(nil, nil)
            }
        } catch let error as NSError {
            dispatch_async(dispatch_get_main_queue(), {
                Logger.logError(error)
                completion(nil, error)
            })
        }
        
    }
    
    // MARK: Helpers
    
    private class func errorForResponse(response: NSHTTPURLResponse, data: NSData?) -> NSError {
        var userInfo = [String: AnyObject]()
        
        userInfo[NSLocalizedFailureReasonErrorKey] = NSHTTPURLResponse.localizedStringForStatusCode(response.statusCode)
        
        // If the API returned an error object, extract the reason and put it in the error description instead
        if data != nil {
            let errorDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: [])
            if let errorDescription = errorDictionary["error"] {
                userInfo[NSLocalizedDescriptionKey] = errorDescription
            }
        }
        
        let error: NSError = NSError(domain: "", code: response.statusCode, userInfo: userInfo)
        Logger.logError(error)
        
        return error
    }
    
}

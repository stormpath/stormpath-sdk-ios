//
//  APIService.swift
//  Stormpath
//
//  Created by Adis on 18/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

internal final class APIService: NSObject {
    weak var stormpath: Stormpath!
    
    init(withStormpath stormpath: Stormpath) {
        self.stormpath = stormpath
    }
    
    // MARK: Registration
    
    internal func register(userDictionary: Dictionary<String, String>, completionHandler: CompletionBlockWithDictionary) {
        
        let registerURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.registerEndpoint)
        let request = APIRequest(URL: registerURL)
        
        request.HTTPMethod = "POST"
        
        Logger.logRequest(request)
        
        if let HTTPBodyData: NSData = try? NSJSONSerialization.dataWithJSONObject(userDictionary, options: []) {
            request.HTTPBody = HTTPBodyData
            
            let session: NSURLSession = NSURLSession.sharedSession()
            
            let task: NSURLSessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                guard let response = response where error == nil else {
                    Logger.logError(error!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(nil, error)
                    })
                    
                    return
                }
                
                let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
                Logger.logResponse(HTTPResponse, data: data)
                
                if HTTPResponse.statusCode != 200 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(nil, APIService._errorForResponse(HTTPResponse, data: data))
                    })
                } else {
                    APIService.parseRegisterHeaderData(HTTPResponse)
                    APIService.parseDictionaryResponseData(data, completionHandler: completionHandler)
                }
            })
            
            task.resume()
        } else {
            Logger.log("NSJSONSerialization failed to convert Dictionary to JSON Object")
        }
    }
    
    // MARK: Login
    
    internal func login(username: String, password: String, completionHandler: CompletionBlockWithString) {
        
        let OAuthURL: NSURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.oauthEndpoint)
        let request = APIRequest(URL: OAuthURL)
        
        // Generate the form data, the data posted MUST be a form
        let body: String = String(format: "username=%@&password=%@&grant_type=password",
            APIService._URLEncodedString(username),
            APIService._URLEncodedString(password))
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        Logger.logRequest(request)
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            guard let response = response where error == nil else {
                Logger.logError(error!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionHandler(nil, error)
                })
                
                return
            }
            
            let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
            Logger.logResponse(HTTPResponse, data: data)
            
            if HTTPResponse.statusCode != 200 {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionHandler(nil, APIService._errorForResponse(HTTPResponse, data: data))
                })
            } else {
                APIService.parseLoginResponseData(data, completionHandler: completionHandler)
            }
        })
        
        task.resume()
        
    }
    
    // MARK: Access token refresh
    
    internal func refreshAccessToken(completionHandler: CompletionBlockWithString) {
        
        let OAuthURL: NSURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.oauthEndpoint)
        let request = APIRequest(URL: OAuthURL)
        
        // Generate the form data, the data posted MUST be a form
        if let refreshToken = KeychainService.refreshToken {
            let body: String = String(format: "refresh_token=%@&grant_type=refresh_token", refreshToken)
            
            request.HTTPMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
            
            Logger.logRequest(request)
            
            let session: NSURLSession = NSURLSession.sharedSession()
            
            let task: NSURLSessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                guard let response = response where error == nil else {
                    Logger.logError(error!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(nil, error)
                    })
                    
                    return
                }
                
                let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
                Logger.logResponse(HTTPResponse, data: data)
                
                if HTTPResponse.statusCode != 200 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(nil, APIService._errorForResponse(HTTPResponse, data: data))
                    })
                } else {
                    APIService.parseLoginResponseData(data, completionHandler: completionHandler)
                }
            })
            
            task.resume()
        } else {
            let error = NSError(domain: OAuthURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(nil, error)
            })
        }
        
    }
    
    // MARK: User data
    
    internal func me(completionHandler: CompletionBlockWithDictionary) {
        
        let meURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.meEndpoint)
        let request = APIRequest(URL: meURL)
        request.HTTPMethod = "GET"
        
        // Fetch the user data
        if let accessToken = KeychainService.accessToken {
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            
            Logger.logRequest(request)
            
            let session = NSURLSession.sharedSession()
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                guard let response = response where error == nil else {
                    Logger.logError(error!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(nil, error)
                    })
                    
                    return
                }
                
                let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
                Logger.logResponse(HTTPResponse, data: data)
                
                if HTTPResponse.statusCode != 200 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(nil, APIService._errorForResponse(HTTPResponse, data: data))
                    })
                } else {
                    APIService.parseDictionaryResponseData(data, completionHandler: completionHandler)
                }
                
            })
            
            task.resume()
        } else {
            let error = NSError(domain: meURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(nil, error)
            })
        }
        
    }
    
    // MARK: Logout
    
    internal func logout(completionHandler: CompletionBlockWithError) {
        
        let logoutURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.logoutEndpoint)
        let request = APIRequest(URL: logoutURL)
        request.HTTPMethod = "GET"
        
        Logger.logRequest(request)
        
        // Regardless of how the API calls goes, we can logout the user locally
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task: NSURLSessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            guard let response = response where error == nil else {
                Logger.logError(error!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionHandler(error)
                })
                
                return
            }
            
            Logger.logResponse(response as! NSHTTPURLResponse, data: data)
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(error)
            })
        })
        
        task.resume()
        
    }
    
    // MARK: Forgot password
    
    internal func resetPassword(email: String, completionHandler: CompletionBlockWithError) {
     
        let resetPasswordURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.forgotPasswordEndpoint)
        let request = APIRequest(URL: resetPasswordURL)
        request.HTTPMethod = "POST"
        
        Logger.logRequest(request)
        
        let emailDictionary: Dictionary = ["email": email]
        
        if let HTTPBodyData: NSData = try! NSJSONSerialization.dataWithJSONObject(emailDictionary, options: []) {
            request.HTTPBody = HTTPBodyData
            
            Logger.logRequest(request)
            
            let session: NSURLSession = NSURLSession.sharedSession()
            
            let task: NSURLSessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                guard let response = response where error == nil else {
                    Logger.logError(error!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(error)
                    })
                    
                    return
                }
                
                Logger.logResponse(response as! NSHTTPURLResponse, data: data)
                
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(error)
                })
            })
            
            task.resume()
        } else {
            Logger.log("NSJSONSerialization failed to convert Dictionary to JSON Object")
        }
        
    }
    
    // MARK: Parse response data
    
    internal class func parseRegisterHeaderData(response: NSHTTPURLResponse) {
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
        }
    }
    
    internal class func parseDictionaryResponseData(data: NSData?, completionHandler: CompletionBlockWithDictionary) {
        
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
    
    internal class func parseLoginResponseData(data: NSData?, completionHandler: CompletionBlockWithString) {
        
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
    
    // MARK: Helpers
    
    private class func _errorForResponse(response: NSHTTPURLResponse, data: NSData?) -> NSError {
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
    
    // There's an argument to be made for this to be a string category, but since this is the only method and only needed for this class...
    
    // Custom URL encode, 'cos iOS is missing one. This one is blatantly stolen from AFNetworking's implementation of percent escaping and converted to Swift
    
    private class func _URLEncodedString(string: String) -> String {
        let charactersGeneralDelimitersToEncode = ":#[]@"
        let charactersSubDelimitersToEncode     = "!$&'()*+,;="
        
        let allowedCharacterSet: NSMutableCharacterSet = NSCharacterSet.URLHostAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        
        allowedCharacterSet.removeCharactersInString(charactersGeneralDelimitersToEncode.stringByAppendingString(charactersSubDelimitersToEncode))
        
        return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet)!
    }
    
}

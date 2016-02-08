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
    
    internal func register(newUser: RegistrationModel, completionHandler: CompletionBlockWithDictionary) {
        
        let registerURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.registerEndpoint)
        
        let requestManager = RegistrationAPIRequestManager(withURL: registerURL, newUser: newUser, callback: completionHandler)
        requestManager.begin()
        
    }
    
    // MARK: Login
    
    internal func login(username: String, password: String, completionHandler: CompletionBlockWithString) {
        
        let oauthURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.oauthEndpoint)
        let requestManager = OAuthAPIRequestManager(withURL: oauthURL, username: username, password: password, callback: completionHandler)
        requestManager.begin()
        
    }
    
    // MARK: Access token refresh
    
    internal func refreshAccessToken(completionHandler: CompletionBlockWithString) {
        let oauthURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.oauthEndpoint)
        
        guard let refreshToken = KeychainService.refreshToken else {
            let error = NSError(domain: oauthURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(nil, error)
            })
            return
        }
        
        let requestManager = OAuthAPIRequestManager(withURL: oauthURL, refreshToken: refreshToken, callback: completionHandler)
        requestManager.begin()
        
    }
    
    // MARK: User data
    
    internal func me(completionHandler: CompletionBlockWithDictionary) {
        let meURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.meEndpoint)
        
        guard let accessToken = KeychainService.accessToken else {
            let error = NSError(domain: meURL.absoluteString, code: 401, userInfo: [NSLocalizedDescriptionKey: "Refresh token not found. Have you logged in yet?"])
            
            Logger.logError(error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(nil, error)
            })
            return
        }
        
        let requestManager = MeAPIRequestManager(withURL: meURL, accessToken: accessToken, callback: completionHandler)
        requestManager.begin()
    }
    
    // MARK: Logout
    
    internal func logout(completionHandler: CompletionBlockWithError) {
        
        let logoutURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.logoutEndpoint)
        let request = NSMutableURLRequest(URL: logoutURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
        
        Logger.logRequest(request)
        
        // Regardless of how the API calls goes, we can logout the user locally
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil
        
        // TODO: Hit the API to delete the access token, because this literally does nothing right now. 
        
    }
    
    // MARK: Forgot password
    
    internal func resetPassword(email: String, completionHandler: CompletionBlockWithError) {
     
        let resetPasswordURL = stormpath.configuration.APIURL.URLByAppendingPathComponent(stormpath.configuration.forgotPasswordEndpoint)
        let requestManager = ResetPasswordAPIRequestManager(withURL: resetPasswordURL, email: email, callback: completionHandler)
        requestManager.begin()
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
    
    class func _errorForResponse(response: NSHTTPURLResponse, data: NSData?) -> NSError {
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
    
    class func _URLEncodedString(string: String) -> String {
        let charactersGeneralDelimitersToEncode = ":#[]@"
        let charactersSubDelimitersToEncode     = "!$&'()*+,;="
        
        let allowedCharacterSet: NSMutableCharacterSet = NSCharacterSet.URLHostAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        
        allowedCharacterSet.removeCharactersInString(charactersGeneralDelimitersToEncode.stringByAppendingString(charactersSubDelimitersToEncode))
        
        return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet)!
    }
    
}

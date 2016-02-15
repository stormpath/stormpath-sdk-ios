//
//  RegistrationAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class RegistrationAPIRequestManager: APIRequestManager {
    var user: RegistrationModel
    var callback: StormpathUserCallback
    
    init(withURL url: NSURL, newUser user: RegistrationModel, callback: StormpathUserCallback) {
        self.user = user
        self.callback = callback
        super.init(withURL: url)
    }
    
    override func prepareForRequest() {
        let registrationDictionary = ["username": user.username, "email": user.email, "password": user.password, "givenName": user.givenName, "surname": user.surname]
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(registrationDictionary, options: [])
    }
    
    override func requestDidFinish(data: NSData, response: NSHTTPURLResponse) {
        RegistrationAPIRequestManager.parseRegisterHeaderData(response)
        
        if let user = User(fromJSON: data) {
            executeCallback(user, error: nil)
        } else {
            executeCallback(nil, error: StormpathError.APIResponseError) 
        }
    }
    
    override func executeCallback(parameters: AnyObject?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.callback(parameters as? User, error)
        }
    }
    
    private class func parseRegisterHeaderData(response: NSHTTPURLResponse) {
//        guard let headerFields = response.allHeaderFields as? [String: String], cookies: [NSHTTPCookie] = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: response.URL!) else {
//            return
//        }
//        
//        var foundToken: Bool = false
//        
//        //TODO: this shouldn't be hitting keychainservice directly
//        for cookie in cookies {
//            if cookie.name == "access_token" {
//                KeychainService.saveString(cookie.value, key: AccessTokenKey)
//                foundToken = true
//            }
//            
//            if cookie.name == "refresh_token" {
//                KeychainService.saveString(cookie.value, key: RefreshTokenKey)
//            }
//        }
//        
//        if (foundToken == false) {
//            Logger.log("There was no access_token in the register cookies, if you want to skip the login after registration, enable the autologin in your Express app.")
//        }
    }
}

//TODO: allow customData

public class RegistrationModel {
    var givenName: String
    var surname: String
    var email: String
    var password: String
    var username = ""
    
    init(withGivenName givenName: String, surname: String, email: String, password: String) {
        self.givenName = givenName
        self.surname = surname
        self.email = email
        self.password = password
    }
}
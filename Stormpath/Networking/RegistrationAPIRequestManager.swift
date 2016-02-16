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
        var registrationDictionary: [String: AnyObject] = ["username": user.username, "email": user.email, "password": user.password, "givenName": user.givenName, "surname": user.surname]
        
        if let customData = user.customData.dataUsingEncoding(NSUTF8StringEncoding), customDataJSON = try? NSJSONSerialization.JSONObjectWithData(customData, options: []) {
            registrationDictionary["customData"] = customDataJSON
        } else {
            Logger.log("Invalid customData JSON passed into registration method")
        }
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(registrationDictionary, options: [])
    }
    
    override func requestDidFinish(data: NSData, response: NSHTTPURLResponse) {
        if let user = User(fromJSON: data) {
            executeCallback(user, error: nil)
        } else {
            executeCallback(nil, error: StormpathError.APIResponseError) 
        }
    }
    
    override func executeCallback(parameters: AnyObject?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.callback(parameters as? User, error)
        }
    }
}

/**
 Model for the user registration form. The fields requested in the initializer 
 are required. The username is optional, but if not set retains the value of the 
 email address.
 */
public class RegistrationModel {
    public var givenName: String
    public var surname: String
    public var email: String
    public var password: String
    public var username = ""
    public var customData = "{}"
    
    /**
     Initializer for Registration Model. After initialization, all fields can be 
     modified. 
     
     - parameters:
       - givenName: Given (first) name of the user.
       - surname: Sur (last) name of the user.
       - email: Email address of the user.
       - password: Password for the user.
     */
    public init(withGivenName givenName: String, surname: String, email: String, password: String) {
        self.givenName = givenName
        self.surname = surname
        self.email = email
        self.password = password
    }
}
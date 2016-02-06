//
//  RegistrationAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

typealias RegistrationAPIRequestCallback = ((NSDictionary?, NSError?) -> Void)

class RegistrationAPIRequestManager: APIRequestManager {
    var user: RegistrationModel
    var callback: RegistrationAPIRequestCallback
    
    init(withURL url: NSURL, newUser user: RegistrationModel, callback: RegistrationAPIRequestCallback) {
        self.user = user
        self.callback = callback
        super.init(withURL: url)
    }
    
    override func prepareForRequest() -> NSMutableURLRequest {
        let request = super.prepareForRequest()
        
        let registrationDictionary = ["username": user.username, "email": user.email, "password": user.password, "givenName": user.givenName, "surname": user.surname]
        
        request.HTTPMethod = "POST"
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(registrationDictionary, options: [])
        
        return request
    }
    
    override func requestDidFinish(data: NSData?, response: NSURLResponse?, error: NSError?) {
        guard let response = response as? NSHTTPURLResponse where error == nil else {
            Logger.logError(error!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.callback(nil, error)
            })
            return
        }
        
        Logger.logResponse(response, data: data)
        
        if response.statusCode != 200 {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.callback(nil, APIService._errorForResponse(response, data: data))
            })
        } else {
            APIService.parseRegisterHeaderData(response)
            APIService.parseDictionaryResponseData(data, completionHandler: callback)
        }
    }
}

class RegistrationModel {
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
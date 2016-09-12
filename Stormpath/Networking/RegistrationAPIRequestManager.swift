//
//  RegistrationAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class RegistrationAPIRequestManager: APIRequestManager {
    var account: RegistrationModel
    var callback: StormpathAccountCallback
    
    init(withURL url: URL, newAccount account: RegistrationModel, callback: @escaping StormpathAccountCallback) {
        self.account = account
        self.callback = callback
        super.init(withURL: url)
    }
    
    override func prepareForRequest() {
        request.httpMethod = "POST"
        request.httpBody = account.jsonData
    }
    
    override func requestDidFinish(_ data: Data, response: HTTPURLResponse) {
        if let user = Account(fromJSON: data) {
            performCallback(user, error: nil)
        } else {
            performCallback(StormpathError.APIResponseError)
        }
    }
    
    override func performCallback(_ error: NSError?) {
        performCallback(nil, error: error)
    }
    
    func performCallback(_ account: Account?, error: NSError?) {
        DispatchQueue.main.async {
            self.callback(account, error)
        }
    }
}

/**
 Model for the account registration form. The fields requested in the initializer 
 are required.
 */
public class RegistrationModel: NSObject {
    
    /**
     Given (first) name of the user. Required by default, but can be turned off 
     in the Framework configuration.
     */
    public var givenName = ""
    
    /**
     Sur (last) name of the user. Required by default, but can be turned off in 
     the Framework configuration.
     */
    public var surname = ""
    
    /// Email address of the user. Only validated server-side at the moment.
    public var email: String
    
    /// Password for the user. Only validated server-side at the moment.
    public var password: String
    
    /**
     Username. Optional, but if not set retains the value of the email address.
     */
    public var username = ""
    
    /**
     Custom fields may be configured in the server-side API. Include them in 
     this
     */
    public var customFields = [String: String]()
    
    /**
     Initializer for Registration Model. After initialization, all fields can be 
     modified. 
     
     - parameters:
       - givenName: Given (first) name of the user.
       - surname: Sur (last) name of the user.
       - email: Email address of the user.
       - password: Password for the user.
     */
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    var jsonData: Data? {
        var registrationDictionary: [String: Any] = customFields
        let accountDictionary = ["username": username, "email": email, "password": password, "givenName": givenName, "surname": surname]
        
        for (key, value) in accountDictionary {
            if value != "" {
                registrationDictionary[key] = value
            }
        }
        
        return try? JSONSerialization.data(withJSONObject: registrationDictionary, options: [])
    }
}

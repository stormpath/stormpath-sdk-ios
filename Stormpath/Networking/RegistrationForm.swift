//
//  RegistrationAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

/**
 Model for the account registration form. The fields requested in the initializer 
 are required.
 */
@objc(SPHRegistrationForm)
public class RegistrationForm: NSObject {
    
    /**
     Given (first) name of the user.
     */
    public var givenName = ""
    
    /**
     Sur (last) name of the user.
     */
    public var surname = ""
    
    /// Email address of the user.
    public var email: String
    
    /// Password for the user.
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
     Initializer for Registration Form. After initialization, all fields can be 
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
    
    var asDictionary: [String: Any] {
        var registrationDictionary: [String: Any] = customFields
        let accountDictionary = ["username": username, "email": email, "password": password, "givenName": givenName, "surname": surname]
        
        for (key, value) in accountDictionary {
            if value != "" {
                registrationDictionary[key] = value
            }
        }
        
        return registrationDictionary
    }
}

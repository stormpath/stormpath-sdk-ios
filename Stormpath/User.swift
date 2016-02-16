//
//  User.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/11/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

/**
 User represents a user object from the Stormpath database.
*/
public class User: NSObject {
    /// Stormpath resource URL for the user
    internal(set) public var href: NSURL!
    
    /// Username of the user. Separate from the email, but is often set to the email address.
    internal(set) public var username: String!
    
    /// Email address of the user.
    internal(set) public var email: String!
    
    /// Given (first) name of the user.
    internal(set) public var givenName: String!
    
    /// Middle name of the user. Optional.
    internal(set) public var middleName: String?
    
    /// Sur (last) name of the user.
    internal(set) public var surname: String!
    
    /// Full name of the user.
    public var fullName: String {
        return middleName == nil || middleName == "" ? "\(givenName) \(surname)" : "\(givenName) \(middleName) \(surname)"
    }
    
    /// Date the user was created in the Stormpath database.
    internal(set) public var createdAt: NSDate!
    
    /// Date the user was last modified in the Stormpath database.
    internal(set) public var modifiedAt: NSDate!
    
    /// A string of JSON representing the custom data for the user. Cannot be updated in the current version of the SDK.
    internal(set) public var customData: String?
    
    /// Initializer for the JSON object for the account. Expected to be wrapped in `{account: accountObject}`
    init?(fromJSON jsonData: NSData) {
        super.init()
        guard let rootJSON = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: []),
            json = rootJSON["account"] as? [String: AnyObject],
            hrefString = json["href"] as? String,
            href = NSURL(string: hrefString),
            username = json["username"] as? String,
            email = json["email"] as? String,
            givenName = json["givenName"] as? String,
            surname = json["surname"] as? String,
            createdAt = (json["createdAt"] as? String)?.dateFromISO8601Format,
            modifiedAt = (json["modifiedAt"] as? String)?.dateFromISO8601Format else {
                return nil
        }
        
        self.href = href
        self.username = username
        self.email = email
        self.givenName = givenName
        self.middleName = json["middleName"] as? String
        self.surname = surname
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        if let customDataObject = json["customData"] as? [String: AnyObject],
            customDataData = try? NSJSONSerialization.dataWithJSONObject(customDataObject, options: []),
            customDataString = String(data: customDataData, encoding: NSUTF8StringEncoding) {
            self.customData = customDataString
        }
    }
}

/// Helper extension to make optional chaining easier. 
private extension String {
    var dateFromISO8601Format: NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(self)
    }
}
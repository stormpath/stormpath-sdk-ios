//
//  Account.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/11/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

/**
 Account represents an account object from the Stormpath database.
*/
public class Account: NSObject {
    /// Stormpath resource URL for the account
    internal(set) public var href: NSURL!
    
    /// Username of the user. Separate from the email, but is often set to the email
    /// address.
    internal(set) public var username: String!
    
    /// Email address of the account.
    internal(set) public var email: String!
    
    /**
     Given (first) name of the user. Will appear as "UNKNOWN" on platforms
     that do not require `givenName`
     */
    internal(set) public var givenName: String!
    
    /// Middle name of the user. Optional.
    internal(set) public var middleName: String?
    
    /**
    Sur (last) name of the user. Will appear as "UNKNOWN" on platforms that do not require `surname`
    */
    internal(set) public var surname: String!
    
    /// Full name of the user.
    public var fullName: String {
        return (middleName == nil || middleName == "") ? "\(givenName) \(surname)" : "\(givenName) \(middleName!) \(surname)"
    }
    
    /// Date the account was created in the Stormpath database.
    internal(set) public var createdAt: NSDate!
    
    /// Date the account was last modified in the Stormpath database.
    internal(set) public var modifiedAt: NSDate!
    
    /// Status of the account. Useful if email verification is needed.
    internal(set) public var status: AccountStatus
    
    /// A string of JSON representing the custom data for the account. Cannot be updated in the current version of the SDK.
    internal(set) public var customData: String?
    
    /// Initializer for the JSON object for the account. Expected to be wrapped in `{account: accountObject}`
    init?(fromJSON jsonData: NSData) {
        self.status = .Enabled //will be overridden below; hack to allow obj-c to access property since primitive types can't be optional
        
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
            modifiedAt = (json["modifiedAt"] as? String)?.dateFromISO8601Format,
            status = json["status"] as? String else {
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
        
        switch status {
        case "ENABLED":
            self.status = AccountStatus.Enabled
        case "UNVERIFIED":
            self.status = AccountStatus.Unverified
        case "DISABLED":
            self.status = AccountStatus.Disabled
        default:
            return nil
        }
        
        if let customDataObject = json["customData"] as? [String: AnyObject],
            customDataData = try? NSJSONSerialization.dataWithJSONObject(customDataObject, options: []),
            customDataString = String(data: customDataData, encoding: NSUTF8StringEncoding) {
            self.customData = customDataString
        }
    }
}

/// Stormpath Account Status
@objc public enum AccountStatus: Int {
    //It's an int for Obj-C compatibility
    
    /// Enabled means that we can login to this account
    case Enabled
    
    /// Unverified is the same as disabled, but a user can enable it by
    /// clicking on the activation email.
    case Unverified
    
    /// Disabled means that users cannot log in to the account.
    case Disabled
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
//
//  User.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/11/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

public class User: NSObject {
    internal(set) public var href: NSURL!
    internal(set) public var username: String!
    internal(set) public var email: String!
    internal(set) public var givenName: String!
    internal(set) public var middleName: String?
    internal(set) public var surname: String!
    public var fullName: String {
        return middleName == nil || middleName == "" ? "\(givenName) \(surname)" : "\(givenName) \(middleName) \(surname)"
    }
    internal(set) public var createdAt: NSDate!
    internal(set) public var modifiedAt: NSDate!
    internal(set) public var customData: String!
    
    init?(fromJSON jsonData: NSData) {
        super.init()
        guard let json = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: []),
            hrefString = json["href"] as? String,
            href = NSURL(string: hrefString),
            username = json["username"] as? String,
            email = json["email"] as? String,
            givenName = json["givenName"] as? String,
            surname = json["surname"] as? String,
            createdAt = (json["createdAt"] as? String)?.dateFromISO8601Format,
            modifiedAt = (json["modifiedAt"] as? String)?.dateFromISO8601Format,
            customDataObject = json["customData"],
            customDataObject2 = customDataObject, //For some reason we need to unwrap twice?? What?? TODO: look into why Swift does this
            customDataData = try? NSJSONSerialization.dataWithJSONObject(customDataObject2, options: []),
            customDataString = String(data: customDataData, encoding: NSUTF8StringEncoding) else {
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
        self.customData = customDataString
    }
}

private extension String {
    var dateFromISO8601Format: NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(self)
    }
}
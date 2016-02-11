//
//  User.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/11/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

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
    internal(set) public var accessToken: AccessToken!
    var refreshToken: String?
    
    init?(withBuilder builder: UserBuilder) {
        super.init()
        guard let href = builder.href, username = builder.username, email = builder.email, givenName = builder.givenName, surname = builder.surname, createdAt = builder.createdAt, modifiedAt = builder.modifiedAt, customData = builder.customData, accessToken = builder.accessToken else {
            return nil
        }
        self.href = href
        self.username = username
        self.email = email
        self.givenName = givenName
        self.middleName = builder.middleName
        self.surname = surname
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.customData = customData
        self.accessToken = accessToken
        self.refreshToken = builder.refreshToken
    }
    
//    init?(fromJSON jsonData: NSData) {
//        let json = NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
//        
//    }
}

internal struct UserBuilder {
    var href: NSURL?
    var username: String?
    var email: String?
    var givenName: String?
    var middleName: String?
    var surname: String?
    var createdAt: NSDate?
    var modifiedAt: NSDate?
    var customData: String?
    var accessToken: AccessToken?
    var refreshToken: String?
}
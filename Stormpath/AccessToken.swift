//
//  AccessToken.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/11/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

public class AccessToken: NSObject {
    public let tokenString: String
    public let expirationDate: NSDate
    public var isExpired: Bool {
        return expirationDate.timeIntervalSinceNow < 0
    }
    
    init(withString token: String, expirationDate: NSDate) {
        self.tokenString = token
        self.expirationDate = expirationDate
    }
}

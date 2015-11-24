//
//  KeychainService.swift
//  Stormpath
//
//  Created by Adis on 17/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

let accesTokenKey: String   = "StormpathAccessTokenKey"
let refreshTokenKey: String = "StormpathRefreshTokenKey"

class KeychainService: NSObject {
    
    // This class does not yet use the keychain, will do in the future
    
    class func save(data: String, key: String) {
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: key)
    }
    
    class func loadData(key: String) -> String {
        let data: String = NSUserDefaults.standardUserDefaults().objectForKey(key) as! String
        return data
    }
    
}

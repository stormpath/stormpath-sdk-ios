//
//  AccountStore.swift
//  Stormpath
//
//  Created by Edward Jiang on 12/15/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

class AccountStore {
    let href: URL
    let providerId: String
    let authorizeURL: URL
    
    init?(json: JSON) {
        guard let hrefString = json["href"].string,
            let href = URL(string: hrefString),
            let providerId = json["provider"]["providerId"].string,
            let authorizeURLString = json["authorizeUri"].string,
            let authorizeURL = URL(string: authorizeURLString) else {
                return nil
        }
        
        self.href = href
        self.providerId = providerId
        self.authorizeURL = authorizeURL
    }
}

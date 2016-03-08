//
//  StormpathLoginProviderApplication.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/8/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

public class StormpathLoginProviderApplication: NSObject {
    public let urlScheme: String
    public let appId: String
    
    init(appId: String, urlScheme: String) {
        self.urlScheme = urlScheme
        self.appId = appId
    }
}
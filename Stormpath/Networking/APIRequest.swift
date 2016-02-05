//
//  APIRequest.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/4/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

class APIRequest: NSMutableURLRequest {
    
    override init(URL: NSURL, cachePolicy: NSURLRequestCachePolicy, timeoutInterval: NSTimeInterval) {
        super.init(URL: URL, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        
        setValue("application/json", forHTTPHeaderField: "Accept")
        setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    convenience init(URL: NSURL) {
        self.init(URL: URL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 60)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  MeAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

typealias MeAPIRequestCallback = ((NSDictionary?, NSError?) -> Void)

class MeAPIRequestManager: APIRequestManager {
    var callback: MeAPIRequestCallback
    init(withURL url: NSURL, accessToken: String, callback: MeAPIRequestCallback) {
        self.callback = callback
        super.init(withURL: url)
        setAccessToken(accessToken)
    }
    
    override func requestDidFinish(data: NSData, response: NSHTTPURLResponse) {
        MeAPIRequestManager.parseDictionaryResponseData(data, completionHandler: callback)
    }
    
    override func executeCallback(parameters: AnyObject?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.callback(parameters as? NSDictionary, error)
        }
    }
    
}
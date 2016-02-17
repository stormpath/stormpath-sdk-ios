//
//  MeAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class MeAPIRequestManager: APIRequestManager {
    var callback: StormpathAccountCallback
    init(withURL url: NSURL, accessToken: String, callback: StormpathAccountCallback) {
        self.callback = callback
        super.init(withURL: url)
        setAccessToken(accessToken)
    }
    
    override func requestDidFinish(data: NSData, response: NSHTTPURLResponse) {
        guard let account = Account(fromJSON: data) else {
            executeCallback(nil, error: StormpathError.APIResponseError)
            return
        }
        executeCallback(account, error: nil)
    }
    
    override func executeCallback(parameters: AnyObject?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.callback(parameters as? Account, error)
        }
    }
    
}
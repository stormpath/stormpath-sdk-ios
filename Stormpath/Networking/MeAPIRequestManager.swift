//
//  MeAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class MeAPIRequestManager: APIRequestManager {
    var callback: StormpathUserCallback
    init(withURL url: NSURL, accessToken: String, callback: StormpathUserCallback) {
        self.callback = callback
        super.init(withURL: url)
        setAccessToken(accessToken)
    }
    
    override func requestDidFinish(data: NSData, response: NSHTTPURLResponse) {
        guard let user = User(fromJSON: data) else {
            executeCallback(nil, error: StormpathError.APIResponseError)
            return
        }
        executeCallback(user, error: nil)
    }
    
    override func executeCallback(parameters: AnyObject?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.callback(parameters as? User, error)
        }
    }
    
}
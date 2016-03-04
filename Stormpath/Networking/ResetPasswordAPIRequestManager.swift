//
//  ResetPasswordAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/8/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

typealias ResetPasswordAPIRequestCallback = ((NSError?) -> Void)

class ResetPasswordAPIRequestManager: APIRequestManager {
    var email: String
    var callback: ResetPasswordAPIRequestCallback
    
    init(withURL url: NSURL, email: String, callback: ResetPasswordAPIRequestCallback) {
        self.email = email
        self.callback = callback
        super.init(withURL: url)
    }
    
    override func prepareForRequest() {
        request.HTTPMethod = "POST"
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(["email": email], options: [])
    }
    
    override func requestDidFinish(data: NSData, response: NSHTTPURLResponse) {
        performCallback(error: nil)
    }
    
    override func performCallback(error error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.callback(error)
        }
    }

}
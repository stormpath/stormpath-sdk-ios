//
//  ResetPasswordAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/8/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

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
        request.HTTPBody = try?NSJSONSerialization.dataWithJSONObject(["email": email], options: [])
    }
    
    override func requestDidFinish(data: NSData?, response: NSURLResponse?, error: NSError?) {
        guard let response = response where error == nil else {
            Logger.logError(error!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.callback(error)
            })

            return
        }

        Logger.logResponse(response as! NSHTTPURLResponse, data: data)

        dispatch_async(dispatch_get_main_queue(), {
            self.callback(error)
        })
    }

}
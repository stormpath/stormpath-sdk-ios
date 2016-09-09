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
    
    init(withURL url: URL, email: String, callback: @escaping ResetPasswordAPIRequestCallback) {
        self.email = email
        self.callback = callback
        super.init(withURL: url)
    }
    
    override func prepareForRequest() {
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["email": email], options: [])
    }
    
    override func requestDidFinish(_ data: Data, response: HTTPURLResponse) {
        performCallback(nil)
    }
    
    override func performCallback(_ error: NSError?) {
        DispatchQueue.main.async { 
            self.callback(error)
        }
    }

}

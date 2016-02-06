//
//  APIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

class APIRequestManager: NSObject {
    var url: NSURL
    var request = NSMutableURLRequest()
    
    init(withURL url: NSURL) {
        self.url = url
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    func begin() {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: requestDidFinish)
        task.resume()
    }
    
    func prepareForRequest() {
        preconditionFailure("Method not implemented")
    }
    
    func requestDidFinish(data: NSData?, response: NSURLResponse?, error: NSError?) {
        preconditionFailure("Method not implemented")
    }
    
    func setAccessToken(accessToken: String) {
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
    }
}

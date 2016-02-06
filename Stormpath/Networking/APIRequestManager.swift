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
    
    init(withURL url: NSURL) {
        self.url = url
    }
    
    func begin() {
        let request = prepareForRequest()
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: requestDidFinish)
        task.resume()
    }
    
    func prepareForRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest()
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func requestDidFinish(data: NSData?, response: NSURLResponse?, error: NSError?) {
        preconditionFailure("Method not implemented")
    }
}

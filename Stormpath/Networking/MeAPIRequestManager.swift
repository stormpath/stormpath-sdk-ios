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
    
    override func requestDidFinish(data: NSData?, response: NSURLResponse?, error: NSError?) {
        guard let response = response where error == nil else {
            Logger.logError(error!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.callback(nil, error)
            })

            return
        }

        let HTTPResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
        Logger.logResponse(HTTPResponse, data: data)

        if HTTPResponse.statusCode != 200 {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.callback(nil, APIRequestManager.errorForResponse(HTTPResponse, data: data))
            })
        } else {
            MeAPIRequestManager.parseDictionaryResponseData(data, completionHandler: callback)
        }
    }
    
}
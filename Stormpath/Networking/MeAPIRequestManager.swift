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
    init(withURL url: URL, accessToken: String, callback: @escaping StormpathAccountCallback) {
        self.callback = callback
        super.init(withURL: url)
        setAccessToken(accessToken)
    }
    
    override func requestDidFinish(_ data: Data, response: HTTPURLResponse) {
        guard let account = Account(fromJSON: data) else {
            performCallback(StormpathError.APIResponseError)
            return
        }
        performCallback(account, error: nil)
    }
    
    override func performCallback(_ error: NSError?) {
        performCallback(nil, error: error)
    }
    
    func performCallback(_ account: Account?, error: NSError?) {
        DispatchQueue.main.async {
            self.callback(account, error)
        }
    }
}

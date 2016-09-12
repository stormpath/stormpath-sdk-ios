//
//  OAuthAPIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class OAuthAPIRequestManager: APIRequestManager {
    var requestBody: String
    var callback: AccessTokenCallback
    
    private init(withURL url: URL, requestBody: String, callback: @escaping AccessTokenCallback) {
        self.requestBody = requestBody
        self.callback = callback
        
        super.init(withURL: url)
    }
    
    convenience init(withURL url: URL, username: String, password: String, callback: @escaping AccessTokenCallback) {
        let requestBody = "username=\(username.formURLEncoded)&password=\(password.formURLEncoded)&grant_type=password"
        
        self.init(withURL: url, requestBody: requestBody, callback: callback)
    }
    
    convenience init(withURL url: URL, refreshToken: String, callback: @escaping AccessTokenCallback) {
        let requestBody = String(format: "refresh_token=%@&grant_type=refresh_token", refreshToken)
        
        self.init(withURL: url, requestBody: requestBody, callback: callback)
    }
    
    override func prepareForRequest() {
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody.data(using: String.Encoding.utf8)
    }
    
    override func requestDidFinish(_ data: Data, response: HTTPURLResponse) {
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
            let accessToken = json["access_token"] as? String else {
            //Callback and return
            performCallback(StormpathError.APIResponseError)
            return
        }
        let refreshToken = json["refresh_token"] as? String
        
        performCallback(accessToken, refreshToken: refreshToken, error: nil)
    }
    
    override func performCallback(_ error: NSError?) {
        performCallback(nil, refreshToken: nil, error: error)
    }
    
    func performCallback(_ accessToken: String?, refreshToken: String?, error: NSError?) {
        DispatchQueue.main.async { 
            self.callback(accessToken, refreshToken, error)
        }
    }
}

// Custom URL encode, 'cos iOS is missing one. This one is blatantly stolen from AFNetworking's implementation of percent escaping and converted to Swift

private extension String {
    var formURLEncoded: String {
        let charactersGeneralDelimitersToEncode = ":#[]@"
        let charactersSubDelimitersToEncode     = "!$&'()*+,;="
        
        var allowedCharacterSet: CharacterSet = CharacterSet.init(bitmapRepresentation: CharacterSet.urlHostAllowed.bitmapRepresentation)
		
        allowedCharacterSet.remove(charactersIn: charactersGeneralDelimitersToEncode + charactersSubDelimitersToEncode)
		
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)!
    }
}

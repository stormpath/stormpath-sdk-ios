//
//  GoogleLoginProvider.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/8/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class GoogleLoginProvider: NSObject, LoginProvider {
    var urlSchemePrefix = "com.googleusercontent.apps."
    private var state = arc4random_uniform(10000000)
    private var application: StormpathSocialProviderConfiguration? // Hacky, but we need to persist this state because Google needs a 2nd step in its request
    
    
    func authenticationRequestURL(_ application: StormpathSocialProviderConfiguration) -> URL {
        self.application = application
        let scopes = application.scopes ?? "email profile"
        let queryString = "response_type=code&scope=\(scopes)&redirect_uri=\(application.urlScheme):/oauth2callback&client_id=\(application.appId)&verifier=\(state)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return URL(string: "https://accounts.google.com/o/oauth2/auth?\(queryString)")!
    }
    
    func getResponseFromCallbackURL(_ url: URL, callback: @escaping LoginProviderCallback) {
        // If the application is not set, we can't continue because we can't 
        // consume the auth code. This should not happen.
        guard let application = application else {
            callback(nil, StormpathError.InternalSDKError)
            return
        }
        
        if(url.queryDictionary["error"] != nil) {
            // We are not even going to callback, because the user never started
            // the login process in the first place. Error is always because
            // people cancelled the login. (or a SDK error)
            return
        }
        
        // If we don't have an error or an auth code, something went wrong with 
        // the SDK implementation.
        guard let authorizationCode = url.queryDictionary["code"] else {
            callback(nil, StormpathError.InternalSDKError)
            return
        }
        
        // We have the auth code, now we (as the client) need to get an access 
        // token, since we're on mobile and Stormpath doesn't take this type of 
        // auth code.
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let url = URL(string: "https://www.googleapis.com/oauth2/v4/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "client_id=\(application.appId)&code=\(authorizationCode)&grant_type=authorization_code&redirect_uri=\(application.urlScheme):/oauth2callback&verifier=\(state)".data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            guard let data = data, let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any], let accessToken = json["access_token"] as? String else {
                callback(nil, StormpathError.InternalSDKError) // This request should not fail.
                return
            }
            callback(LoginProviderResponse(data: accessToken, type: .accessToken), nil)
        }
        task.resume()
    }
}

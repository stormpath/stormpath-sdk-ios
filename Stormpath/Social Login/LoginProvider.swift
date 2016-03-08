//
//  LoginProvider.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/7/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

typealias LoginProviderCallback = (LoginProviderResponse?, NSError?) -> Void

/// Protocol for external OAuth handlers
protocol LoginProvider {
    var urlSchemePrefix: String { get }
    func getResponseFromCallbackURL(url: NSURL, callback: LoginProviderCallback)
    func authenticationRequestURL(application: StormpathSocialProviderConfiguration) -> NSURL
}

/// Contains the access token or auth code
struct LoginProviderResponse {
    var data: String
    var type: LoginProviderResponseType
}

enum LoginProviderResponseType {
    case AccessToken, AuthorizationCode
}

extension NSURL {
    /// Dictionary with key/value pairs from the URL fragment
    var fragmentDictionary: [String: String] {
        return dictionaryFromFormEncodedString(fragment)
    }
    
    /// Dictionary with key/value pairs from the URL query string
    var queryDictionary: [String: String] {
        return dictionaryFromFormEncodedString(query)
    }
    
    private func dictionaryFromFormEncodedString(input: String?) -> [String: String] {
        var result = [String: String]()
        
        guard let input = input else {
            return result
        }
        let inputPairs = input.componentsSeparatedByString("&")
        
        for pair in inputPairs {
            let split = pair.componentsSeparatedByString("=")
            if split.count == 2 {
                if let key = split[0].stringByRemovingPercentEncoding, value = split[1].stringByRemovingPercentEncoding {
                    result[key] = value
                }
            }
        }
        return result
    }
}
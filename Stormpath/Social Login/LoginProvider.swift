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
    func getResponseFromCallbackURL(_ url: URL, callback: @escaping LoginProviderCallback)
    func authenticationRequestURL(_ application: StormpathSocialProviderConfiguration) -> URL
}

/// Contains the access token or auth code
struct LoginProviderResponse {
    var data: String
    var type: LoginProviderResponseType
}

enum LoginProviderResponseType {
    case accessToken, authorizationCode
}

extension URL {
    /// Dictionary with key/value pairs from the URL fragment
    var fragmentDictionary: [String: String] {
        return dictionaryFromFormEncodedString(fragment)
    }
    
    /// Dictionary with key/value pairs from the URL query string
    var queryDictionary: [String: String] {
        return dictionaryFromFormEncodedString(query)
    }
    
    private func dictionaryFromFormEncodedString(_ input: String?) -> [String: String] {
        var result = [String: String]()
        
        guard let input = input else {
            return result
        }
        let inputPairs = input.components(separatedBy: "&")
        
        for pair in inputPairs {
            let split = pair.components(separatedBy: "=")
            if split.count == 2 {
                if let key = split[0].removingPercentEncoding, let value = split[1].removingPercentEncoding {
                    result[key] = value
                }
            }
        }
        return result
    }
}

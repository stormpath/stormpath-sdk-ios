//
//  LoginProvider.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/7/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

protocol LoginProvider {
    func getResponseFromCallbackURL(url: NSURL) throws -> LoginProviderResponse
    func authenticationRequestURL(scopes: [String], urlScheme: StormpathLoginProviderURLScheme) -> NSURL
}

struct LoginProviderResponse {
    var data: String
    var type: LoginProviderResponseType
}

enum LoginProviderResponseType {
    case AccessToken, AuthorizationCode
}

public class StormpathLoginProviderURLScheme: NSObject {
    public let urlScheme: String
    public let appId: String
    
    init(urlScheme: String, appId: String) {
        self.urlScheme = urlScheme
        self.appId = appId
    }
}

extension NSURL {
    var fragmentDictionary: [String: String] {
        var result = [String: String]()
        
        guard let fragment = fragment else {
            return result
        }
        let fragmentPairs = fragment.componentsSeparatedByString("&")
        
        for pair in fragmentPairs {
            let split = pair.componentsSeparatedByString("=")
            if let key = split[0].stringByRemovingPercentEncoding, value = split[1].stringByRemovingPercentEncoding {
                result[key] = value
            }
        }
        return result
    }
}